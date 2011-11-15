/*
    Copyright 2010 Marco Martin <notmart@gmail.com>

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Library General Public
    License as published by the Free Software Foundation; either
    version 2 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Library General Public License for more details.

    You should have received a copy of the GNU Library General Public License
    along with this library; see the file COPYING.LIB.  If not, write to
    the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
    Boston, MA 02110-1301, USA.
*/

import QtQuick 1.0
import org.kde.plasma.components 0.1 as PlasmaComponents
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents
import org.kde.plasma.slccomponents 0.1 as SlcComponents

Item {
    id: main
    width: 400
    height: 150

    signal itemLaunched()

    function resetStatus()
    {
        searchField.searchQuery = ""
        appGrid.currentPage = 0
        //tagCloud.resetStatus()
    }

    Image {
        id: background
        width: parent.width * 1.5
        height:parent.height
        source: "image://appbackgrounds/contextarea"
        fillMode: Image.Tile
        x: -((width-parent.width) * (appGrid.currentPage / appGrid.pagesCount))
        Behavior on x {
            NumberAnimation {
                duration: 250
                easing.type: Easing.InOutQuad
            }
        }
    }

    MobileComponents.ResourceInstance {
        id: resourceInstance
    }

    SlcComponents.SlcMenu {
        id: contextMenu
    }

    PlasmaCore.Theme {
        id: theme
    }

    /*
    TagCloud {
        id:tagCloud
    }*/
    Item {
        id: tagCloud
        height: 200
        anchors {
            left: parent.left
            top: parent.top
            right: parent.right
        }
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
    ListModel {
        id: emptyModel
    }


    MobileComponents.ViewSearch {
        id: searchField

        Item {
            id: everythingButton
            x: enabled?parent.width/6:-width-10
            anchors.verticalCenter: parent.verticalCenter
            width: everythingPushButton.width
            height: everythingPushButton.height
            enabled: false

            PlasmaComponents.Button {
                id: everythingPushButton

                text: i18n("Show everything")

                onEnabledChanged: NumberAnimation {
                                    duration: 250
                                    target: everythingButton
                                    properties: "x"
                                    easing.type: Easing.InOutQuad
                                }
                //onClicked: tagCloud.resetStatus()
            }
            Behavior on x {
                NumberAnimation {
                    duration: 250
                    easing.type: Easing.InOutQuad
                }
            }
        }

        anchors {
            left: parent.left
            right: parent.right
            top: tagCloud.bottom
        }

        onSearchQueryChanged: {
            if (searchQuery.length < 3) {
                appGrid.model = emptyModel
                appGrid.model = appsModel
                runnerSource.connectedSources = []
            } else {
                //limit to just some runners
                runnerSource.connectedSources = [searchQuery+":services|nepomuksearch|recentdocuments|desktopsessions|PowerDevil"]
                appGrid.model = runnerModel
            }
        }
    }

    MobileComponents.IconGrid {
        id: appGrid
        delegateWidth: 128
        delegateHeight: 100
        model: appsModel
        onCurrentPageChanged: resourceInstance.uri = ""

        delegate: Component {
            MobileComponents.ResourceDelegate {
                width: appGrid.delegateWidth
                height: appGrid.delegateHeight
                className: "FileDataObject"
                genericClassName: "FileDataObject"
                property string label: model["name"]?model["name"]:model["text"]
                property string mimeType: model["mimeType"]?model["mimeType"]:"application/x-desktop"
                onPressAndHold: {
                    resourceInstance.uri = model["resourceUri"]?model["resourceUri"]:model["entryPath"]
                    resourceInstance.title = model["name"]?model["name"]:model["text"]
                }
                onClicked: {
                    //showing apps model?
                    if (searchField.searchQuery == "") {
                        var service = appsSource.serviceForSource(appsSource.connectedSources[0])
                        var operation = service.operationDescription("launch")

                        operation["Path"] = model["entryPath"]
                        service.startOperationCall(operation)
                    } else {
                        var service = runnerSource.serviceForSource(runnerSource.connectedSources[0])
                        var operation = service.operationDescription("run")

                        operation["id"] = model["id"]
                        service.startOperationCall(operation)
                    }
                    resetStatus()
                    itemLaunched()
                }

            }
        }

        anchors {
            left: parent.left
            right: parent.right
            top: searchField.bottom
            bottom: parent.bottom
            margins: 4
        }
    }
}


