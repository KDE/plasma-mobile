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
import org.kde.plasma.extras 0.1 as PlasmaExtraComponents
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents
import org.kde.draganddrop 1.0


Item {
    anchors.fill: parent

    Column {
        id: toolsColumn
        spacing: 4
        enabled: fileBrowserRoot.model == metadataModel
        opacity: enabled ? 1 : 0.6
        anchors {
            left: parent.left
            right: parent.right
        }

        PlasmaExtraComponents.Heading {
            text: i18n("Rating")
            anchors {
                top: parent.top
                right: parent.right
                rightMargin: theme.defaultFont.mSize.width
            }
        }

        MobileComponents.Rating {
            anchors {
                left: parent.left
                leftMargin: theme.defaultFont.mSize.width
            }
            onScoreChanged: metadataModel.minimumRating = score
        }

        Component.onCompleted: {
            if (!exclusiveResourceType && exclusiveMimeTypes.length == 0) {
                typeFilterLoader.source = "TypeFilter.qml"
            }
        }

        Item {
            width: 1
            height: theme.defaultFont.mSize.height
        }
        Loader {
            id: typeFilterLoader
            anchors {
                left: parent.left
                right: parent.right
            }
            //sourceComponent: TypeFilter { }
        }
    }


    PlasmaCore.DataModel {
        id: devicesModel
        dataSource: hotplugSource
    }

    Flow {
        id: devicesFlow
        spacing: 4
        anchors {
            right: parent.right
            bottom: parent.bottom
            left: parent.left
        }

        property int itemCount: 1
        property string currentUdi

        PlasmaComponents.ToolButton {
            id: localButton
            width: theme.hugeIconSize + 10
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
                width: theme.hugeIconSize + 10
                height: width
                visible: devicesSource.data[udi]["Removable"] == true
                iconSource: model["icon"]
                onClicked: checked = true
                onCheckedChanged: {
                    if (checked) {
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
            width: theme.hugeIconSize + 10
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
                }
            }
        }
    }
}
