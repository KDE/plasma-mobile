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

import QtQuick 1.0
import org.kde.metadatamodels 0.1 as MetadataModels
import org.kde.plasma.components 0.1 as PlasmaComponents
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents
import org.kde.plasma.slccomponents 0.1 as SlcComponents
import org.kde.qtextracomponents 0.1


PlasmaComponents.Page {
    anchors {
        fill: parent
        topMargin: toolBar.height
    }

    tools: Item {
        width: parent.width
        height: childrenRect.height

        PlasmaCore.DataSource {
            id: hotplugSource
            engine: "hotplug"
            connectedSources: sources
        }
        PlasmaCore.DataSource {
            id: devicesSource
            engine: "soliddevice"
            connectedSources: hotplugSource.sources
        }
        PlasmaCore.DataModel {
            id: devicesModel
            dataSource: hotplugSource
        }

        Row {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            spacing: 8
            opacity: (imageViewer.state == "browsing") ? 1 : 0
            MobileComponents.IconButton {
                icon: QIcon("drive-harddisk")
                opacity: resultsGrid.model == metadataModel ? 0.2 : 1
                width: 48
                height: 48
                onClicked: {
                    resultsGrid.model = metadataModel
                }
            }
            Repeater {
                model: devicesModel
                MobileComponents.IconButton {
                    id: deviceButton
                    icon: QIcon(model["icon"])
                    //FIXME: use the declarative branch in workspace that tells about removable
                    visible: devicesSource.data[udi]["Removable"] == true
                    opacity: (dirModel.url == devicesSource.data[udi]["File Path"] && resultsGrid.model == dirModel) ? 1 : 0.2
                    width: 48
                    height: 48
                    onClicked: {
                        dirModel.url = devicesSource.data[udi]["File Path"]
                        resultsGrid.model = dirModel
                    }
                }
            }
        }

        MobileComponents.ViewSearch {
            id: searchBox
            anchors {
                left: parent.left
                right: parent.right
                verticalCenter: parent.verticalCenter
            }
            onSearchQueryChanged: {
                metadataModel.queryString = "*"+searchBox.searchQuery+"*"
            }
        }
    }

    MobileComponents.IconGrid {
        id: resultsGrid
        anchors.fill: parent

        model: metadataModel
        delegateWidth: 130
        delegateHeight: 120
        delegate: MobileComponents.ResourceDelegate {
            id: resourceDelegate
            className: model["className"]?model["className"]:"Image"
            width: 130
            height: 120
            infoLabelVisible: false
            property string label: model["label"]?model["label"]:model["display"]

            onPressAndHold: {
                resourceInstance.uri = model["url"]?model["url"]:model["resourceUri"]
                resourceInstance.title = model["label"]
            }

            onClicked: {
                if (mimeType == "inode/directory") {
                    dirModel.url = model["url"]
                    resultsGrid.model = dirModel
                } else {
                    loadImage(model["url"])
                }
            }
        }
    }
}

