/*
 *   Copyright 2010 Marco Martin <notmart@gmail.com>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
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
import org.kde.metadatamodels 0.1 as MetadataModels
import org.kde.runnermodel 0.1 as RunnerModels

PlasmaComponents.Sheet {
    id: widgetsExplorer
    objectName: "widgetsExplorer"
    title: i18n("Add Items")
    acceptButtonText: i18n("Add Items")
    rejectButtonText: i18n("Cancel")

    signal addAppletRequested(string plugin)
    signal closeRequested

    function addItems()
    {
        var service = metadataSource.serviceForSource("")
        var operation = service.operationDescription("connectToActivity")
        operation["ActivityUrl"] = activitySource.data["Status"]["Current"]

        for (var i = 0; i < selectedModel.count; ++i) {
            var item = selectedModel.get(i)
            if (item.resourceUri) {
                operation["ResourceUrl"] = item.resourceUri
                service.startOperationCall(operation)
            } else if (item.pluginName) {
                widgetsExplorer.addAppletRequested(item.pluginName)
            }
        }

    }

    //used only toexplicitly close the keyboard
    TextInput { id: inputPanelController; width:0; height:0}

    PlasmaCore.DataSource {
        id: metadataSource
        engine: "org.kde.active.metadata"
    }

    Binding {
        target: acceptButton
        property: "enabled"
        value: selectedModel.count > 0
    }

    onAccepted: {
        widgetsExplorer.addItems()
    }
    onStatusChanged: {
        if (status == PlasmaComponents.DialogStatus.Closed) {
            closeRequested()
        }
    }

    ListModel {
        id: selectedModel
    }

    MetadataModels.MetadataUserTypes {
        id: userTypes
    }

    MetadataModels.MetadataCloudModel {
        id: cloudModel
        cloudCategory: "rdf:type"
        allowedCategories: userTypes.userTypes
    }

    PlasmaCore.DataSource {
        id: activitySource
        engine: "org.kde.activities"
        connectedSources: ["Status"]
        interval: 0
    }

    Timer {
        running: true
        interval: 100
        onTriggered: open()
    }

    content: [
        MobileComponents.ViewSearch {
            id: searchField
            MobileComponents.IconButton {
                icon: QIcon("go-previous")
                width: 32
                height: 32
                onClicked: {
                    searchField.searchQuery = ""
                    stack.pop()
                }
                opacity: stack.depth > 1 ? 1 : 0
                Behavior on opacity {
                    NumberAnimation {
                        duration: 250
                        easing.type: Easing.InOutQuad
                    }
                }
            }
            busy: {
                if (stack.currentPage.model && stack.currentPage.model.running !== undefined) {
                    stack.currentPage.model.running
                } else {
                    false
                }
            }

            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
            }
        },
        MenuTabBar {
            id: tabBar
        },
        PlasmaComponents.PageStack {
            id: stack
            clip: true
            anchors {
                left: parent.left
                right: parent.right
                top: tabBar.bottom
                bottom: parent.bottom
            }
            initialPage: tabBar.startComponent
        }
    ]

    Component {
        id: globalSearchComponent
        ResourceBrowser {
            model: MetadataModels.MetadataModel {
                id: runnerModel
                queryString: searchField.searchQuery.length > 3 ? "*" + searchField.searchQuery + "*" : ""
                onQueryStringChanged: {
                    if (searchField.searchQuery.length <= 3) {
                        stack.pop()
                    }
                }
                Component.onCompleted: {
                    runnerModel.finishedListingChanged.connect(searchField.setIdle)
                }
            }
        }
    }
}
