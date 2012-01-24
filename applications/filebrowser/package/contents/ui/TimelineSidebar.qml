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
    anchors {
        fill: parent
        topMargin: toolBar.height + theme.defaultFont.mSize.width
        leftMargin: theme.defaultFont.mSize.width * 2
        margins: theme.defaultFont.mSize.width
    }


    Item {
        id: timeline
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        Flickable {
            id: timelineFlickable
            anchors.fill: parent

            contentWidth: contents.width
            contentHeight: contents.height

            Item {
                id: contents
                width: childrenRect.width
                height: childrenRect.height

                Rectangle {
                    color: theme.textColor
                    width: 5
                    height: timelineColumn.height + 32
                    anchors.horizontalCenter: timelineColumn.horizontalCenter
                }
                Column {
                    id: timelineColumn
                    spacing: 40
                    y: 16
                    Repeater {
                        id: timelineRepeater
                        model: MetadataModels.MetadataTimelineModel {
                            id: metadataTimelineModel
                            level: MetadataModels.MetadataTimelineModel.Year
                            //queryString: "pdf"
                            //resourceType: "nfo:Document"
                            //activityId: "12c8a6ea-c99b-4a54-bf42-a4e8fbcb9be7"
                            //startDate: "2011-01-01"
                            //endDate: "2011-12-31"
                            //tags: ["kde"]
                            //minimumRating: 5
                            //allowedCategories: userTypes.userTypes
                        }

                        delegate: Rectangle {
                            color: theme.textColor
                            width: 14 + 100 * (model.count / metadataTimelineModel.totalCount)
                            height: width
                            radius: width/2
                            anchors.horizontalCenter: parent.horizontalCenter
                            PlasmaComponents.Label {
                                text: model.label
                                anchors {
                                    left: parent.right
                                    verticalCenter: parent.verticalCenter
                                }
                            }
                        }
                    }
                }
            }
        }
        PlasmaComponents.ScrollBar {
            flickableItem: timelineFlickable
            orientation: Qt.Vertical
        }
    }


    PlasmaComponents.Button {
        anchors {
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
        }
        text: i18n("Back")
        onClicked: sidebarStack.pop()
    }
}
