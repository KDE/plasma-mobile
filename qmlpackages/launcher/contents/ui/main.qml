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

import Qt 4.7
import org.kde.plasma.graphicswidgets 0.1 as PlasmaWidgets
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents
import org.kde.plasma.slccomponents 0.1 as SlcComponents

Item {
    id: main
    width: 400
    height: 150


    MobileComponents.ResourceInstance {
        id: resourceInstance
    }

    SlcComponents.SlcMenu {
        id: contextMenu
    }

    PlasmaCore.Theme {
        id: theme
    }

    TagCloud {
        id:tagCloud
    }


    PlasmaCore.DataSource {
        id: appsSource
        engine: "org.kde.active.apps"
        connectedSources: ["Apps"]
        interval: 0
    }
    PlasmaCore.DataModel {
        id: appsModel
        keyRoleFilter: ".*"
        dataSource: appsSource
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


    MobileComponents.ViewSearch {
        id: searchField

        anchors {
            left: parent.left
            right: parent.right
            top: tagCloud.bottom
        }

        onSearchQueryChanged: {
            if (searchQuery == "") {
                runnerSource.connectedSources = []
            } else {
                //limit to just some runners
                runnerSource.connectedSources = [searchQuery+":services|nepomuksearch|recentdocuments"]
            }
        }
    }

    MobileComponents.IconGrid {
        id: appGrid
        delegateWidth: 128
        delegateHeight: 100
        model: (searchField.searchQuery == "")?appsModel:runnerModel
        delegate: Component {
            MobileComponents.ResourceDelegate {
                width: appGrid.delegateWidth
                height: appGrid.delegateHeight
                className: "FileDataObject"
                genericClassName: "FileDataObject"
                property string label: model["name"]?model["name"]:model["text"]
                property string mimeType: model["mimeType"]?model["mimeType"]:"application/x-desktop"
                onPressed: {
                    resourceInstance.uri = model["resourceUri"]?model["resourceUri"]:model["entryPath"]
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


