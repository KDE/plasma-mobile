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
 *   GNU Library General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 1.0
import org.kde.plasma.components 0.1 as PlasmaComponents
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents
import org.kde.qtextracomponents 0.1
import org.kde.metadatamodels 0.1 as MetadataModels

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
        }
        ScriptAction {
            script: main.destroy()
        }
    }

    PlasmaCore.DataSource {
        id: metadataSource
        engine: "org.kde.active.metadata"
    }

    MouseArea {
        anchors.fill: parent
        onClicked: disappearAnimation.running = true
    }


    MetadataModels.MetadataUserTypes {
        id: userTypes
    }

    MetadataModels.MetadataCloudModel {
        id: cloudModel
        cloudCategory: "rdf:type"
        allowedCategories: userTypes.userTypes
    }

    MetadataModels.MetadataModel {
        id: metadataModel
        sortBy: ["nfo:fileName"]
        sortOrder: Qt.AscendingOrder
    }

    ListModel {
        id: selectedModel
    }



    PlasmaCore.DataSource {
        id: appsSource
        engine: "org.kde.active.apps"
        connectedSources: ["Apps"]
        interval: 0
    }
    PlasmaCore.SortFilterModel {
        id: appsModel
        sourceModel: PlasmaCore.DataModel {
            keyRoleFilter: ".*"
            dataSource: appsSource
        }
        sortRole: "name"
    }

    ListModel {
        id: emptyModel
    }

    PlasmaCore.DataSource {
        id: runnerSource
        engine: "org.kde.runner"
        interval: 0
    }
    PlasmaCore.DataModel {
        id: runnerModel
        keyRoleFilter: ".*"
        dataSource: runnerSource
    }


    PlasmaCore.FrameSvgItem {
        id: dialog
        scale: 0
        anchors.fill: parent
        anchors.margins: 50
        imagePath: "dialogs/background"

        MouseArea {
            anchors.fill: parent
            //eat mouse events to mot trigger the dialog hide
            onPressed: mouse.accepted = true
        }

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
                        searchBox.searchQuery = ""
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
                resultsGrid.model = runnerModel
                if (searchBox.searchQuery) {
                    //limit to just some runners
                    runnerSource.connectedSources = [searchBox.searchQuery+":services|nepomuksearch|recentdocuments"]
                    resultsContainer.contentY = 0
                } else {
                    resultsContainer.contentY = resultsContainer.height
                }
                selectedModel.clear()
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
                    delegateWidth: 130
                    delegateHeight: 120

                    delegate: Item {
                        width: resultsGrid.delegateWidth
                        height: resultsGrid.delegateHeight
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
                            //those two are to make appModel and runnerModel work
                            property string label: model["label"]?model["label"]:(model["name"]?model["name"]:model["text"])

                            onPressAndHold: {
                                //take into account cases for all 3 models

                                if (model["url"]) {
                                    resourceInstance.uri = model["url"]
                                } else if (model["resourceUri"]) {
                                    resourceInstance.uri = model["resourceUri"]
                                } else if (model["entryPath"]) {
                                    resourceInstance.uri = model["entryPath"]
                                }

                                if (model["label"]) {
                                    resourceInstance.title = model["label"]
                                } else if (model["name"]) {
                                    resourceInstance.title = model["name"]
                                } else if (model["text"]) {
                                    resourceInstance.title = model["text"]
                                }
                            }
                            onClicked: {
                                //already in the model?
                                //second case, for the apps model
                                for (var i = 0; i < selectedModel.count; ++i) {
                                    if ((model.resourceUri && model.resourceUri == selectedModel.get(i).resourceUri) ||

                                        (model.entryPath && model.entryPath == selectedModel.get(i).resourceUri)) {
                                        highlightFrame.opacity = 0
                                        selectedModel.remove(i)
                                        return
                                    }
                                }

                                var item = new Object
                                item["resourceUri"] = model["resourceUri"]
                                //this is to make AppModel work
                                if (!item["resourceUri"]) {
                                    item["resourceUri"] = model["entryPath"]
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

                Flow {
                    id: categoriesView
                    anchors {
                        left: parent.left
                        right: parent.right
                    }
                    height: resultsContainer.height
                    property int orientation: ListView.Horizontal

                    Repeater {
                        model: ListModel {
                            ListElement {
                                name: "Apps"
                                resourceType: "_Apps"
                                hasSymbol: "application-x-executable"
                            }
                            ListElement {
                                name: "Bookmarks"
                                resourceType: "nfo:Bookmark"
                                hasSymbol: "emblem-favorite"
                            }
                            ListElement {
                                name: "Contacts"
                                resourceType: "nco:Contact"
                                hasSymbol: "view-pim-contacts"
                            }
                            ListElement {
                                name: "Documents"
                                resourceType: "nfo:Document"
                                hasSymbol: "application-vnd.oasis.opendocument.text"
                            }
                            ListElement {
                                name: "Images"
                                resourceType: "nfo:Image"
                                hasSymbol: "image-x-generic"
                            }
                            ListElement {
                                name: "Music"
                                resourceType: "nfo:Audio"
                                hasSymbol: "audio-x-generic"
                            }
                            ListElement {
                                name: "Videos"
                                resourceType: "nfo:Video"
                                hasSymbol: "video-x-generic"
                            }
                            ListElement {
                                name: "Widgets"
                                resourceType: "_PlasmaWidgets"
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
                                visible: String(model["resourceType"]).charAt(0) == "_" || cloudModel.categories.indexOf(model["resourceType"]) != -1

                                onClicked: {
                                    //FIXME: make all of this way cleaner, hardcoding _PlasmaWidgets seems pretty bad
                                    if (model["resourceType"] == "_PlasmaWidgets") {
                                        main.addAction.trigger()
                                        main.destroy()

                                    } else if (model["resourceType"] == "_Apps") {
                                        //BUG in MeeGo's Qt: have to assign an empty model before the actual one
                                        resultsGrid.model = emptyModel
                                        resultsGrid.model = appsModel

                                        resultsContainer.contentY = 0

                                    } else {
                                        metadataModel.resourceType = model["resourceType"]
                                        //exclude already connected resources
                                        metadataModel.activityId = "!"+plasmoid.activityId
                                        metadataModel.sortBy = [userTypes.sortFields[model["resourceType"]]]
                                        resultsGrid.model = metadataModel

                                        resultsContainer.contentY = 0
                                    }
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

            PlasmaComponents.Button {
                id: okButton
                //enabled: selectedResourcesList.count>0

                text: i18n("Add items")
                onClicked : {
                    var service = metadataSource.serviceForSource("")
                    var operation = service.operationDescription("connectToActivity")
                    operation["ActivityUrl"] = plasmoid.activityId

                    for (var i = 0; i < selectedModel.count; ++i) {
                        operation["ResourceUrl"] = selectedModel.get(i).resourceUri
                        service.startOperationCall(operation)
                    }

                    disappearAnimation.running = true
                }
            }

            PlasmaComponents.Button {
                id: closeButton

                text: i18n("Cancel")

                onClicked: {
                    disappearAnimation.running = true
                }
            }
        }
    }
}

