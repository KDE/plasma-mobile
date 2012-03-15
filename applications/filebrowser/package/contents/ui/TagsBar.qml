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


PlasmaComponents.Page {
    id: root
    anchors.fill: parent

    property Item currentItem

    Flickable {
        id: mainFlickable
        contentWidth: mainRow.width
        contentHeight: mainRow.height

        anchors.fill: parent

        Row {
            id: mainRow
            Repeater {
                model: MetadataModels.MetadataCloudModel {
                    id: tagCloud
                    cloudCategory: "nao:hasTag"
                    resourceType: metadataModel.resourceType
                    minimumRating: metadataModel.minimumRating
                }

                Column {
                    MouseArea {
                        height: root.height - tagLabel.height
                        width: height
                        anchors.horizontalCenter: parent.horizontalCenter
                        property bool checked: false

                        Rectangle {
                            color: parent.checked ? theme.highlightColor : theme.textColor
                            radius: width/2
                            anchors.centerIn: parent
                            width: Math.min(parent.width, 10 * model.count)
                            height: width
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
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }
        }
    }
}
