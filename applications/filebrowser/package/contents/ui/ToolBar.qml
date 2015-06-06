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

import QtQuick 2.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.mobilecomponents 0.2 as MobileComponents
import org.kde.kquickcontrolsaddons 2.0
import org.kde.draganddrop 2.0
import org.kde.baloo 0.1 as Baloo

Item {
    width: parent.width
    height: childrenRect.height
    property string currentBalooQueryType: ""

    PlasmaCore.DataModel {
        id: devicesModel
        dataSource: hotplugSource
    }

    Baloo.QueryResultsModel {
        id: balooRestoreModel
    }

    anchors.fill: parent

    Connections {
        target: folderModel.sourceModel
        onResolvedUrlChanged: {
            if (resourceBrowser.currentUdi != "") {
                var devicePath = "file://" + devicesSource.data[resourceBrowser.currentUdi]["File Path"]
                var modelPath = folderModel.sourceModel.resolvedUrl
                upButton.visible = String(modelPath).length > devicePath.length
            }
        }
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
            width: units.iconSizes.large
            height: width
            PlasmaComponents.ToolButton {
                id: upButton
                anchors.fill: parent
                flat: false
                iconSource: "go-up"
                visible: resourceBrowser.currentUdi != ""
                onClicked: folderModel.sourceModel.url = folderModel.sourceModel.url+"/.."
            }
        }

        PlasmaComponents.ToolButton {
            id: localButton
            width: units.iconSizes.medium + 10
            height: width
            iconSource: "drive-harddisk"
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

                    currentBalooQueryType = fileBrowserRoot.model.sourceModel.query !== undefined ? fileBrowserRoot.model.sourceModel.query.type : ""
                    fileBrowserRoot.model.sourceModel = folderModel.sourceModel
                    folderModel.sourceModel.url = devicesSource.data[udi]["File Path"]
                    //nepomuk db, not filesystem
                    resourceBrowser.currentUdi = ""
                } else {
                        fileBrowserRoot.model.sourceModel = balooRestoreModel
                        balooDataModel.sourceModel.query.type = currentBalooQueryType
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
                width: units.iconSizes.medium + 10
                height: width
                visible: devicesSource.data[udi]["Removable"] == true
                iconSource: model["icon"]
                onClicked: checked = !checked
                Component.onCompleted: {
                    checked = folderModel.sourceModel.url.indexOf(devicesSource.data[udi]["File Path"]) > 0
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
                            folderModel.sourceModel.url = devicesSource.data[udi]["File Path"]
                            currentBalooQueryType = fileBrowserRoot.model.sourceModel.query !== undefined ? fileBrowserRoot.model.sourceModel.query.type : ""
                            fileBrowserRoot.model.sourceModel = folderModel.sourceModel
                        } else {
                            var service = devicesSource.serviceForSource(udi);
                            var operation = service.operationDescription("mount");
                            service.startOperationCall(operation);
                        }
                    } else {
                        fileBrowserRoot.model.sourceModel = balooRestoreModel
                        balooDataModel.sourceModel.query.type = currentBalooQueryType
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
            width: units.iconSizes.medium + 10
            height: width
            parent: devicesFlow
            iconSource: "user-trash"
            onClicked: checked = !checked
            onCheckedChanged: {
                if (checked) {
                    for (var i = 0; i < devicesFlow.children.length; ++i) {
                        var child = devicesFlow.children[i]
                        if (child != trashButton && child.checked !== undefined) {
                            child.checked = false
                        }
                    }
                    resourceBrowser.currentUdi = ""
                    currentBalooQueryType = fileBrowserRoot.model.sourceModel.query !== undefined ? fileBrowserRoot.model.sourceModel.query.type : ""
                    folderModel.sourceModel.url = "trash:/"

                    fileBrowserRoot.model.sourceModel = folderModel
                } else {
                    fileBrowserRoot.model.sourceModel = balooRestoreModel
                    balooDataModel.sourceModel.query.type = currentBalooQueryType
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
                    balooDataModel.requestRefresh()
                }
            }
        }
    }

    ViewSearch {
        id: searchBox
        anchors.centerIn: parent
        visible: fileBrowserRoot.model == balooDataModel

        onSearchQueryChanged: {
            if (searchQuery.length > 3) {
                // the "*" are needed for substring match.
                balooDataModel.queryProvider.extraParameters["nfo:fileName"] = "*" + searchBox.searchQuery + "*"
            } else {
                balooDataModel.queryProvider.extraParameters["nfo:fileName"] = ""
            }
        }
        busy: balooDataModel.count < 0
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
                bottomMargin: - toolBar.margins.bottom - 1
            }
            z: 900
            spacing: 0

            height: theme.mSize(theme.defaultFont).height * 1.6
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
                enabled: fileBrowserRoot.model == balooDataModel
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
                enabled: fileBrowserRoot.model == balooDataModel
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
        width: units.iconSizes.large
        height: width
        anchors {
         //   right: tabsRow.left
            verticalCenter: parent.verticalCenter
            rightMargin: y
        }
        visible: fileBrowserRoot.model == folderModel && folderModel.sourceModel.url == "trash:/"
        enabled: folderModel.count > 0
        iconSource: "trash-empty"
        onClicked: application.emptyTrash()
    }

}
