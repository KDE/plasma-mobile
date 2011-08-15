/*
 *   Copyright 2011 Sebastian Kügler <sebas@kde.org>
 *   Copyright 2011 Marco Martin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2 or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 1.0
import org.kde.plasma.graphicswidgets 0.1 as PlasmaWidgets
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents
import org.kde.qtextracomponents 0.1

Rectangle {
    id: main
    color: Qt.rgba(0, 0, 0, 0.4)
    opacity: 0
    anchors.fill: parent
    //FIXME: why has to be added here as a property for trigger() to work?
    property QtObject addAction: plasmoid.action("add widgets")

    function show()
    {
        appearAnimation.running = true
    }

    ParallelAnimation {
        id: appearAnimation
        NumberAnimation {
            targets: main
            properties: "opacity"
            duration: 250
            to: 1
            easing.type: "InOutCubic"
        }
        NumberAnimation {
            targets: dialog
            properties: "scale"
            duration: 250
            to: 1
            easing.type: "InOutCubic"
        }
    }

    SequentialAnimation {
        id: disappearAnimation
        ParallelAnimation {
            NumberAnimation {
                targets: main
                properties: "opacity"
                duration: 250
                to: 0
                easing.type: "InOutCubic"
            }
            NumberAnimation {
                targets: dialog
                properties: "scale"
                duration: 250
                to: 0
                easing.type: "InOutCubic"
            }
            ScriptAction {
                script: main.destroy()
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: disappearAnimation.running = true
    }

    PlasmaCore.DataSource {
        id: metadataSource
        engine: "org.kde.active.metadata"
        interval: 0
    }
    Timer {
       id: queryTimer
       running: true
       repeat: false
       interval: 1000
       onTriggered: {
            if (searchBox.searchQuery) {
                metadataSource.connectedSources = [searchBox.searchQuery]
                resultsContainer.contentY = 0
            } else {
                resultsContainer.contentY = resultsContainer.height
            }
            selectedModel.clear()
       }
    }

    PlasmaCore.DataModel {
        id: metadataModel
        keyRoleFilter: ".*"
        dataSource: metadataSource
    }

    ListModel {
        id: selectedModel
    }

    PlasmaCore.FrameSvgItem {
        id: dialog
        scale: 0
        anchors.fill: parent
        anchors.margins: 50
        imagePath: "dialogs/background"
        MobileComponents.ViewSearch {
            id: searchBox
            anchors {
                left: parent.left
                right:parent.right
                top:parent.top
                leftMargin: parent.margins.left
                rightMargin: parent.margins.right
                topMargin: parent.margins.top
            }

            QIconItem {
                icon: QIcon("go-up")
                width: 32
                height: 32
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        resultsContainer.contentY = resultsContainer.height
                        selectedModel.clear()
                    }
                }
                opacity: resultsContainer.contentY==0?1:0
                Behavior on opacity {
                    NumberAnimation {
                        duration: 250
                        easing.type: Easing.InOutQuad
                    }
                }
            }

            onSearchQueryChanged: {
                queryTimer.running = true
            }
        }
        Flickable {
            id: resultsContainer
            clip: true
            interactive: contentY < height
            onMovementEnded: {
                if (contentY < height/2) {
                    contentY = 0
                } else {
                    contentY = height
                }
                selectedModel.clear()
            }
            contentWidth: resultsColumn.width
            contentHeight: resultsColumn.height
            anchors {
                left: parent.left
                right:parent.right
                top: searchBox.bottom
                bottom: buttonsRow.top
                leftMargin: parent.margins.left
                rightMargin: parent.margins.right
                bottomMargin: parent.margins.bottom
            }
            Behavior on contentY {
                NumberAnimation {
                    duration: 250
                    easing.type: Easing.InOutQuad
                }
            }

            Column {
                id: resultsColumn
                width: resultsContainer.width

                MobileComponents.IconGrid {
                    id: resultsGrid
                    anchors {
                        left: parent.left
                        right:parent.right
                    }

                    Component.onCompleted: resultsContainer.contentY = resultsContainer.height
                    height: resultsContainer.height
                    model: metadataModel
                    delegate: Item {
                        width: 130
                        height: 120
                        PlasmaCore.FrameSvgItem {
                                id: highlightFrame
                                imagePath: "widgets/viewitem"
                                prefix: "selected+hover"
                                opacity: 0
                                width: 130
                                height: 120
                                Behavior on opacity {
                                    NumberAnimation {duration: 250}
                                }
                        }
                        MobileComponents.ResourceDelegate {
                            id: resourceDelegate
                            width: 130
                            height: 120
                            infoLabelVisible: false

                            onClicked: {

                                //already in the model?
                                for (var i = 0; i < selectedModel.count; ++i) {
                                    if (model.resourceUri == selectedModel.get(i).resourceUri) {
                                        highlightFrame.opacity = 0
                                        selectedModel.remove(i)
                                        return
                                    }
                                }

                                var item = new Object
                                for (i in model) {
                                    if (i != "index") {
                                        item[i] = model[i]
                                    }
                                }
                                selectedModel.append(item)
                                highlightFrame.opacity = 1
                            }
                            Component.onCompleted: {
                                //FIXME: horribly inefficient
                                //already in the model?
                                for (var i = 0; i < selectedModel.count; ++i) {
                                    if (model.resourceUri == selectedModel.get(i).resourceUri) {
                                        highlightFrame.opacity = 1
                                        return
                                    }
                                }
                            }
                            //FIXME here too
                            Connections {
                                target: selectedModel
                                onCountChanged: {
                                    if (selectedModel.count == 0) {
                                        highlightFrame.opacity = 0
                                    }
                                }
                            }
                        }
                    }
                }

                GridView {
                    id: categoriesView
                    anchors {
                        left: parent.left
                        right: parent.right
                    }
                    height: resultsContainer.height

                    model: ListModel {
                        ListElement {
                            name: "Contacts"
                            className: "Contact"
                            hasSymbol: "view-pim-contacts"
                        }
                        ListElement {
                            name: "Documents"
                            className: "Document"
                            hasSymbol: "application-vnd.oasis.opendocument.text"
                        }
                        ListElement {
                            name: "Images"
                            className: "Image"
                            hasSymbol: "image-x-generic"
                        }
                        ListElement {
                            name: "Music"
                            className: "Audio"
                            hasSymbol: "audio-x-generic"
                        }
                        ListElement {
                            name: "Videos"
                            className: "Video"
                            hasSymbol: "video-x-generic"
                        }
                        ListElement {
                            name: "Widgets"
                            className: "_PlasmaWidgets"
                            hasSymbol: "dashboard-show"
                        }
                    }
                    delegate: Component {
                        MobileComponents.ResourceDelegate {
                            width: 140
                            height: 120
                            className: "FileDataObject"
                            genericClassName: "FileDataObject"
                            property string label: name
                            property string mimeType: "x"
                            onClicked: {
                                //FIXME: make all of this way cleaner, hardcoding _PlasmaWidgets seems pretty bad
                                if (model["className"] == "_PlasmaWidgets") {
                                    main.addAction.trigger()
                                    main.destroy()
                                } else {
                                    metadataSource.connectedSources = ["ResourcesOfType:"+model["className"]]
                                    resultsContainer.contentY = 0
                                }
                            }
                        }
                    }
                }
            }
        }
        Row {
            id: buttonsRow
            spacing: 8
            anchors {
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
                bottomMargin: dialog.margins.bottom
            }

            PlasmaWidgets.PushButton {
                id: okButton
                //enabled: selectedResourcesList.count>0

                text: i18n("Add items")
                onClicked : {
                    var service = metadataSource.serviceForSource(metadataSource.connectedSources[0])
                    var operation = service.operationDescription("connectToActivity")
                    operation["ActivityUrl"] = plasmoid.activityId

                    for (var i = 0; i < selectedModel.count; ++i) {
                        operation["ResourceUrl"] = selectedModel.get(i).resourceUri
                        service.startOperationCall(operation)
                    }
                    queryTimer.running = true

                    disappearAnimation.running = true
                    /*
                    //FIXME: MEEGO BUG
                    metadataSource.connectedSources = ["x"]
                    metadataSource.connectedSources = ["CurrentActivityResources:"+plasmoid.activityId]*/
                }
            }

            PlasmaWidgets.PushButton {
                id: closeButton

                text: i18n("Cancel")

                onClicked: {
                    disappearAnimation.running = true
                }
            }
        }
    }
}

