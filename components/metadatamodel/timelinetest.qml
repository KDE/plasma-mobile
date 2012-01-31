/*
    Copyright 2011 Marco Martin <notmart@gmail.com>

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

import QtQuick 1.1
import org.kde.plasma.components 0.1
import org.kde.metadatamodels 0.1

Item {
    width: 800
    height: 480

    MetadataUserTypes {
        id: userTypes
    }

    ListView {
        id: metadataList
        clip: true
        anchors {
            left: parent.left
            top: parent.top
            right: parent.right
            bottom: timeline.top
        }

        model: MetadataTimelineModel {
            id: metadataTimelineModel
            level: MetadataTimelineModel.Month
            //queryString: "pdf"
            //resourceType: "nfo:Document"
            //activityId: "12c8a6ea-c99b-4a54-bf42-a4e8fbcb9be7"
            //sortBy: ["nie#url", "nao#lastModified"]
            startDate: "2011-01-01"
            endDate: "2011-12-31"
            //tags: ["kde"]
            //minimumRating: 5
            //allowedCategories: userTypes.userTypes
        }

        delegate: Row {
            spacing: 10
            Text {
                text: model["year"] + "-" + model["month"] + "-" + model["day"]
            }
            Text {
                text: model["count"]
            }
        }
    }
    Button {
        text: (metadataTimelineModel.startDate == "2009-10-10") ? "2011-12-31" : "2009-10-10"
        onClicked: {
            if (metadataTimelineModel.startDate == "2009-10-10") {
                metadataTimelineModel.startDate = "2011-01-01"
                metadataTimelineModel.endDate =  "2011-12-31"
            } else {
                metadataTimelineModel.startDate = "2009-10-10"
                metadataTimelineModel.endDate =  "2011-12-31"
            }
        }
    }

    Item {
        id: timeline
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        height: contents.height

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
                    color: "black"
                    height: 12
                    width: timelineRow.width + 32
                    anchors.verticalCenter: timelineRow.verticalCenter
                }
                Row {
                    id: timelineRow
                    spacing: 40
                    x: 16
                    Repeater {
                        id: timelineRepeater
                        model: metadataTimelineModel
                        delegate: Rectangle {
                            color: "black"
                            width: 14 + 300 * (model.count / metadataTimelineModel.totalCount)
                            height: width
                            radius: width/2
                            anchors.verticalCenter: parent.verticalCenter
                            Text {
                                text: model.label
                                color: "white"
                                anchors.centerIn: parent
                            }
                        }
                    }
                }
            }
        }
        ScrollBar {
            flickableItem: timelineFlickable
            orientation: Qt.Horizontal
        }
    }


    ScrollBar {
        flickableItem: metadataList
        orientation: Qt.Vertical
        anchors {
            top:metadataList.top
            right:metadataList.right
            bottom:metadataList.bottom
        }
    }
}