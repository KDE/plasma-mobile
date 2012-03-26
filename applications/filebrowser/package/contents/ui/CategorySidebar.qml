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


Item {
    anchors.fill: parent

    Column {
        id: toolsColumn
        spacing: 4

        PlasmaComponents.Label {
            text: "<b>"+i18n("Rating")+"</b>"
        }

        MobileComponents.Rating {
            anchors.horizontalCenter: parent.horizontalCenter
            onScoreChanged: metadataModel.minimumRating = score
        }

        Component.onCompleted: {
            if (!exclusiveResourceType) {
                typeFilterLoader.source = "TypeFilter.qml"
            }
        }

        Loader {
            id: typeFilterLoader
            //sourceComponent: TypeFilter { }
        }
    }

    PlasmaCore.DataSource {
        id: hotplugSource
        engine: "hotplug"
        connectedSources: sources
    }
    PlasmaCore.DataSource {
        id: devicesSource
        engine: "soliddevice"
        connectedSources: hotplugSource.sources
        onDataChanged: {
            //access it here due to the async nature of the dataengine
            if (resultsGrid.model != dirModel && devicesSource.data[devicesFlow.currentUdi]["File Path"] != "") {
                dirModel.url = devicesSource.data[devicesFlow.currentUdi]["File Path"]

                fileBrowserRoot.model = dirModel
            }
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


        /*opacity: itemCount > 1 ? 1 : 0
        Behavior on opacity {
            NumberAnimation {
                duration: 250
                easing.type: Easing.InOutQuad
            }
        }*/

        PlasmaComponents.ToolButton {
            id: localButton
            width: theme.hugeIconSize
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
                    devicesFlow.currentUdi = ""
                }
            }
        }


        Repeater {
            id: devicesRepeater
            model: devicesModel

            delegate: PlasmaComponents.ToolButton {
                id: removableButton
                width: theme.hugeIconSize
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
                        devicesFlow.currentUdi = udi

                        if (devicesSource.data[udi]["Accessible"]) {
                            dirModel.url = devicesSource.data[devicesFlow.currentUdi]["File Path"]

                            fileBrowserRoot.model = dirModel
                        } else {
                            var service = devicesSource.serviceForSource(udi);
                            var operation = service.operationDescription("mount");
                            service.startOperationCall(operation);
                        }
                    }
                }
            }
        }

        PlasmaComponents.ToolButton {
            id: trashButton
            width: theme.hugeIconSize
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
                    devicesFlow.currentUdi = ""

                    dirModel.url = "trash:/"

                    fileBrowserRoot.model = dirModel
                }
            }
        }
    }
}
