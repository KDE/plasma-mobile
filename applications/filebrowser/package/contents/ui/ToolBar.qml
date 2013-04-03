/*
 *   Copyright 2011 Marco Martin <mart@kde.org>
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

import QtQuick 1.1
import org.kde.metadatamodels 0.1 as MetadataModels
import org.kde.plasma.components 0.1 as PlasmaComponents
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents
import org.kde.draganddrop 1.0
import org.kde.qtextracomponents 0.1

Item {
    width: parent.width
    height: childrenRect.height

    PlasmaCore.DataModel {
        id: devicesModel
        dataSource: hotplugSource
    }

    Row {
        id: devicesFlow
        spacing: 4
        anchors {
            // bottom: parent.bottom
            verticalCenter: parent.verticalCenter
            left: parent.left
        }

        property int itemCount: 1

        Item {
            width: theme.largeIconSize
            height: width
            PlasmaComponents.ToolButton {
                id: upButton
                anchors.fill: parent
                flat: false
                iconSource: "go-up"
                visible: resourceBrowser.currentUdi != "" &&
                    devicesSource.data[resourceBrowser.currentUdi] &&
                    dirModel.url.indexOf(devicesSource.data[resourceBrowser.currentUdi]["File Path"]) !== -1 &&
                    "file://" + devicesSource.data[resourceBrowser.currentUdi]["File Path"] !== dirModel.url
                onClicked: dirModel.url = dirModel.url+"/.."
            }
        }

        PlasmaComponents.ToolButton {
            id: localButton
            width: theme.mediumIconSize + 10
            height: width
            iconSource: "drive-harddisk"
            checked: fileBrowserRoot.model == metadataModel
            onClicked: checked = true
            onCheckedChanged: {
                if (checked) {
                    for (var i = 0; i < devicesFlow.children.length; ++i) {
                        var child = devicesFlow.children[i]
                        if (child != localButton && child.checked !== undefined) {
                            child.checked = false
                        }
                    }
                    for (child in devicesFlow.children) {
                        if (child != localButton) {
                            child.checked = false
                        }
                    }
                    fileBrowserRoot.model = metadataModel
                    //nepomuk db, not filesystem
                    resourceBrowser.currentUdi = ""
                }
            }
            DropArea {
                enabled: !parent.checked
                anchors.fill: parent
                onDragEnter: parent.flat = false
                onDragLeave: parent.flat = true
                onDrop: {
                    parent.flat = true
                    application.copy(event.mimeData.urls, "~")
                }
            }
        }


        Repeater {
            id: devicesRepeater
            model: devicesModel

            delegate: PlasmaComponents.ToolButton {
                id: removableButton
                width: theme.mediumIconSize + 10
                height: width
                visible: devicesSource.data[udi]["Removable"] == true
                iconSource: model["icon"]
                onClicked: checked = true
                Component.onCompleted: {
                    checked = dirModel.url.indexOf(devicesSource.data[udi]["File Path"]) > 0
                }
                onCheckedChanged: {
                    if (checked && visible) {
                        for (var i = 0; i < devicesFlow.children.length; ++i) {
                            var child = devicesFlow.children[i]
                            if (child != removableButton && child.checked !== undefined) {
                                child.checked = false
                            }
                        }
                        resourceBrowser.currentUdi = udi

                        if (devicesSource.data[udi]["Accessible"]) {
                            dirModel.url = devicesSource.data[udi]["File Path"]

                            fileBrowserRoot.model = dirModel
                        } else {
                            var service = devicesSource.serviceForSource(udi);
                            var operation = service.operationDescription("mount");
                            service.startOperationCall(operation);
                        }
                    }
                }
                DropArea {
                    enabled: !parent.checked
                    anchors.fill: parent
                    onDragEnter: parent.flat = false
                    onDragLeave: parent.flat = true
                    onDrop: {
                        application.copy(event.mimeData.urls, devicesSource.data[udi]["File Path"])
                        parent.flat = true
                    }
                }
            }
        }

        PlasmaComponents.ToolButton {
            id: trashButton
            width: theme.mediumIconSize + 10
            height: width
            parent: devicesFlow
            iconSource: "user-trash"
            onClicked: checked = true
            onCheckedChanged: {
                if (checked) {
                    for (var i = 0; i < devicesFlow.children.length; ++i) {
                        var child = devicesFlow.children[i]
                        if (child != trashButton && child.checked !== undefined) {
                            child.checked = false
                        }
                    }
                    resourceBrowser.currentUdi = ""

                    dirModel.url = "trash:/"

                    fileBrowserRoot.model = dirModel
                }
            }
            DropArea {
                enabled: !parent.checked
                anchors.fill: parent
                onDragEnter: parent.flat = false
                onDragLeave: parent.flat = true
                onDrop: {
                    parent.flat = true
                    application.trash(event.mimeData.urls)
                    metadataModel.requestRefresh()
                }
            }
        }
    }

    MobileComponents.ViewSearch {
        id: searchBox
        anchors.centerIn: parent
        visible: fileBrowserRoot.model == metadataModel

        onSearchQueryChanged: {
            if (searchQuery.length > 3) {
                // the "*" are needed for substring match.
                metadataModel.queryProvider.extraParameters["nfo:fileName"] = "*" + searchBox.searchQuery + "*"
            } else {
                metadataModel.queryProvider.extraParameters["nfo:fileName"] = ""
            }
        }
        busy: metadataModel.running
    }

    Item {
        anchors {
            bottom: parent.bottom
        }
        x: parent.width - resourceBrowser.visibleDrawerWidth + toolBar.margins.left
        z: 900
        PlasmaComponents.ButtonRow {
            id: tabsRow
            anchors {
                bottom: parent.bottom
                bottomMargin: - toolBar.margins.bottom
            }
            z: 900
            spacing: 0

            height: theme.defaultFont.mSize.height * 1.6
            exclusive: true

            PlasmaComponents.ToolButton {
                id: mainTab
                text: i18n("Filters")
                flat: false
                width: sidebar.width / 3
                height: parent.height - 1
                onCheckedChanged: {
                    if (checked) {
                        sidebarTabGroup.currentTab = categorySidebar
                    }
                }
            }

            PlasmaComponents.ToolButton {
                text: i18n("Time")
                enabled: fileBrowserRoot.model == metadataModel
                flat: false
                width: sidebar.width / 3
                height: parent.height - 1
                onCheckedChanged: {
                    if (checked) {
                        sidebarTabGroup.currentTab = timelineSidebar
                    }
                }
            }

            PlasmaComponents.ToolButton {
                text: i18n("Tags")
                enabled: fileBrowserRoot.model == metadataModel
                flat: false
                width: sidebar.width / 3
                height: parent.height - 1
                onCheckedChanged: {
                    if (checked) {
                        sidebarTabGroup.currentTab = tagsSidebar
                    }
                }
            }
            //fake: just to show something then overshooting
            PlasmaComponents.ToolButton {
                flat: false
                width: sidebar.width / 3
                height: parent.height-1
                enabled: false
                opacity: 1
            }
        }
    }

    PlasmaComponents.ToolButton {
        id: emptyTrashButton
        width: theme.largeIconSize
        height: width
        anchors {
            right: tabsRow.left
            verticalCenter: parent.verticalCenter
            rightMargin: y
        }
        visible: fileBrowserRoot.model == dirModel && dirModel.url == "trash:/"
        enabled: dirModel.count > 0
        iconSource: "trash-empty"
        onClicked: application.emptyTrash()
    }

}
