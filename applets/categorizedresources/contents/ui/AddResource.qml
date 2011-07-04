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
                resultsGrid.y = 0
            } else {
                resultsGrid.y = -resultsGrid.height
            }
       }
    }

    PlasmaCore.DataModel {
        id: metadataModel
        keyRoleFilter: ".*"
        dataSource: metadataSource
    }


    PlasmaCore.FrameSvgItem {
        id: dialog
        scale: 0
        anchors.fill: parent
        anchors.margins: 80
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

            onSearchQueryChanged: {
                queryTimer.running = true
            }
        }
        Item {
            id: resultsContainer
            clip: true
            anchors {
                left: parent.left
                right:parent.right
                top: searchBox.bottom
                bottom: parent.bottom
                leftMargin: parent.margins.left
                rightMargin: parent.margins.right
                bottomMargin: parent.margins.bottom
            }

            MobileComponents.IconGrid {
                id: resultsGrid
                anchors {
                    left: parent.left
                    right:parent.right
                }

                Behavior on y {
                    NumberAnimation {
                        duration: 250
                        easing.type: Easing.InOutQuad
                    }
                }

                QIconItem {
                    icon: QIcon("go-up")
                    width: 22
                    height: 22
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            resultsGrid.y = -resultsGrid.height
                        }
                    }
                }
                Component.onCompleted: resultsGrid.y = -resultsGrid.height
                height: resultsContainer.height
                model: metadataModel
                delegate: MobileComponents.ResourceDelegate {
                    id: resourceDelegate
                    width: 130
                    height: 120
                    resourceType: model.resourceType
                    infoLabelVisible: false

                    onClicked: {
                        print(resourceUri)
                        var service = metadataSource.serviceForSource(metadataSource.connectedSources[0])
                        var operation = service.operationDescription("connectToActivity")
                        operation["ActivityUrl"] = plasmoid.activityId
                        operation["ResourceUrl"] = resourceUri
                        service.startOperationCall(operation)
                        queryTimer.running = true

                        disappearAnimation.running = true
                        /*
                        //FIXME: MEEGO BUG
                        metadataSource.connectedSources = ["x"]
                        metadataSource.connectedSources = ["CurrentActivityResources:"+plasmoid.activityId]*/
                    }
                }
            }
            GridView {
                id: categoriesView
                anchors {
                    left: parent.left
                    right: parent.right
                    top: resultsGrid.bottom
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
                }
                delegate: /*Text {
                    text: name
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            metadataSource.connectedSources = ["ResourcesOfType:"+className]
                            resultsGrid.y = 0
                        }
                    }
                }*/
                 Component {
                    MobileComponents.ResourceDelegate {
                        width: 140
                        height: 120
                        property string className: "FileDataObject"
                        resourceType: "FileDataObject"
                        property string label: name
                        property string mimeType: "x"
                        onClicked: {
                            metadataSource.connectedSources = ["ResourcesOfType:"+model["className"]]
                            resultsGrid.y = 0
                        }
                    }
                }
            }
        }
    }
}

