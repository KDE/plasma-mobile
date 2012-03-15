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


PlasmaComponents.Page {
    id: root
    anchors.fill: parent

    property Item currentItem

    PlasmaCore.DataSource {
        id: metadataSource
        engine: "org.kde.active.metadata"
        //connectedSources: []
    }

    Flickable {
        id: mainFlickable
        contentWidth: mainColumn.width
        contentHeight: mainColumn.height

        anchors.fill: parent

        Column {
            id: mainColumn
            Repeater {
                model: MetadataModels.MetadataCloudModel {
                    id: tagCloud
                    cloudCategory: "nao:hasTag"
                    resourceType: metadataModel.resourceType
                    minimumRating: metadataModel.minimumRating
                }

                Row {
                    MouseArea {
                        width: root.width/2
                        height: width
                        property bool checked: false

                        DropArea {
                            anchors.fill: parent
                            onDrop: {
                                var service = metadataSource.serviceForSource("")
                                print(service);
                                var operation = service.operationDescription("tagResources")
                                operation["ResourceUrls"] = event.mimeData.urls
                                operation["Tag"] = model["label"]
                                service.startOperationCall(operation)
                            }

                            Rectangle {
                                color: parent.parent.checked ? theme.highlightColor : theme.textColor
                                radius: width/2
                                anchors.centerIn: parent
                                width: Math.min(parent.width, 10 * model.count)
                                height: width
                            }
                        }
                        onClicked: checked = !checked
                        onCheckedChanged: {
                            var tags = metadataModel.tags
                            if (checked) {
                                tags[tags.length] = model["label"];
                                metadataModel.tags = tags
                            } else {
                                for (var i = 0; i < tags.length; ++i) {
                                    if (tags[i] == model["label"]) {
                                        tags.splice(i, 1);
                                        metadataModel.tags = tags
                                        break;
                                    }
                                }
                            }
                        }
                    }
                    PlasmaComponents.Label {
                        id: tagLabel
                        text: model.label
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }
    }
}
