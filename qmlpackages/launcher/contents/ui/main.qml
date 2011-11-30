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
import org.kde.runnermodel 0.1 as RunnerModels

MouseArea {
    id: main
    width: 400
    height: 150

    //just to hide the keyboard
    onClicked: main.forceActiveFocus()

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

    RunnerModels.RunnerModel {
        id: runnerModel
        runners: [ "services", "nepomuksearch", "recentdocuments", "desktopsessions" , "PowerDevil", "calculator" ]
    }

    MobileComponents.ViewSearch {
        id: searchField

        anchors {
            left: parent.left
            right: parent.right
            top: tagCloud.bottom
            topMargin: 8
        }

        onSearchQueryChanged: {
            if (searchQuery.length < 3) {
                runnerModel.query = ""
                appGrid.model = appsModel
            } else {
                appGrid.model = runnerModel
                runnerModel.query = searchQuery
            }
        }

        Component.onCompleted: {
            delay = 10
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
                property string label: model["name"]?model["name"]:model["label"]
                //property string mimeType: model["mimeType"]?model["mimeType"]:"application/x-desktop"
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
                        runnerModel.run(index)
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
            topMargin: 6
            bottomMargin: 4
        }
    }
}


