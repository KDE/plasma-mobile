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
import org.kde.draganddrop 2.0

Item {
    id: root
    anchors.fill: parent

    property int currentYear: 0
    property int currentMonth: 0
    property Item currentItem

    function buildDate(year, month, day)
    {
        var strMonth = month
        var strDay = day

        if (month < 10) {
            strMonth = "0" + month
        }
        if (day < 10) {
            strDay = "0" + day
        }

        return year + "-" + strMonth + "-" + strDay
    }



    Rectangle {
        color: Qt.tint(theme.textColor, Qt.rgba(1,1,1,0.7))
        width: 6
        anchors {
            top: parent.top
            bottom: parent.bottom
        }
        x: timelineColumn.width/2 - 4
    }

    PlasmaExtras.Heading {
        id: titleLabel
        anchors {
            right: parent.right
            rightMargin: theme.defaultFont.mSize.width
        }
        text: metadataTimelineModel.queryProvider.description
    }

     PlasmaExtras.ScrollArea {
        anchors.fill: parent

        Flickable {
            id: timelineFlickable
        /* anchors {
                fill: parent
                top: titleLabel.bottom
                topMargin: 40
            }*/
            interactive: true

            contentWidth: width
            contentHeight: timelineColumn.height + 40


            Item {
                width: parent.width
                height: timelineColumn.height

                PlasmaComponents.Highlight {
                    id: highlight
                    opacity: currentItem != null ? 1 : 0
                    width: root.width
                    height: Math.max(currentItem.height, theme.largeIconSize + 8)
                    x: 0
                    y: currentItem.y - (height/2 - currentItem.height/2)
                    Behavior on y {
                        NumberAnimation {
                            duration: 250
                            easing.type: "InOutCubic"
                        }
                    }
                    Behavior on opacity {
                        NumberAnimation {
                            duration: 250
                            easing.type: "OutCubic"
                        }
                    }
                }

                PlasmaComponents.ToolButton {
                    iconSource: "zoom-in"
                    z: 900
                    anchors {
                        right: highlight.right
                        verticalCenter: highlight.verticalCenter
                        rightMargin: 8
                    }
                    width: theme.largeIconSize
                    opacity: highlight.opacity
                    visible: metadataTimelineModel.queryProvider.level != MetadataModels.TimelineQueryProvider.Day
                    height: width
                    flat: false
                    enabled: metadataTimelineModel.queryProvider.level != MetadataModels.TimelineQueryProvider.Day
                    onClicked: {
                        switch (metadataTimelineModel.queryProvider.level) {
                        case MetadataModels.TimelineQueryProvider.Year:
                            metadataTimelineModel.queryProvider.startDate = buildDate(currentYear, 1, 1)
                            metadataTimelineModel.queryProvider.endDate = buildDate(currentYear, 12, 31)
                            metadataTimelineModel.queryProvider.level = MetadataModels.TimelineQueryProvider.Month
                            break
                        case MetadataModels.TimelineQueryProvider.Month:
                            metadataTimelineModel.queryProvider.startDate = buildDate(currentYear, currentMonth, 1)
                            metadataTimelineModel.queryProvider.endDate = buildDate(currentYear, currentMonth+1, 1)
                            metadataTimelineModel.queryProvider.level = MetadataModels.TimelineQueryProvider.Day
                            break
                        }
                        currentItem = null
                    }
                }
                Column {
                    id: timelineColumn
                    spacing: 40
                    Repeater {
                        id: timelineRepeater
                        model: MetadataModels.MetadataModel {
                            id: metadataTimelineModel
                            queryProvider: MetadataModels.TimelineQueryProvider {
                                level: MetadataModels.TimelineQueryProvider.Year
                                resourceType: metadataModel.queryProvider.resourceType
                                tags: metadataModel.queryProvider.tags
                                minimumRating: metadataModel.queryProvider.minimumRating
                                //activityId: "12c8a6ea-c99b-4a54-bf42-a4e8fbcb9be7"
                                //startDate: "2011-01-01"
                                //endDate: "2011-12-31"
                            }
                        }

                        delegate: Rectangle {
                            id: dateDelegate
                            color: currentItem == dateDelegate ? theme.highlightColor : theme.textColor
                            Behavior on color {
                                ColorAnimation {
                                    duration: 250
                                }
                            }
                            width: Math.round(14 + 100 * (model.count / metadataTimelineModel.totalCount))
                            height: width
                            radius: width/2
                            anchors.horizontalCenter: parent.horizontalCenter
                            PlasmaComponents.Label {
                                text: model.label
                                anchors {
                                    left: parent.horizontalCenter
                                    leftMargin: timelineColumn.width/2 + theme.defaultFont.mSize.width
                                    verticalCenter: parent.verticalCenter
                                }
                            }
                            MouseArea {
                                anchors {
                                    fill: parent
                                    rightMargin: - timelineFlickable.width + parent.width
                                }
                                onClicked: {
                                    if (currentItem == dateDelegate) {
                                        switch (metadataTimelineModel.queryProvider.level) {
                                        case MetadataModels.TimelineQueryProvider.Year:
                                            metadataModel.queryProvider.startDate = ""
                                            metadataModel.queryProvider.endDate = ""

                                            currentMonth = 0
                                            currentYear = 0
                                            break
                                        case MetadataModels.TimelineQueryProvider.Month:
                                            metadataModel.queryProvider.startDate = buildDate(model.year, 1, 1)
                                            metadataModel.queryProvider.endDate = buildDate(model.year, 12, 31)

                                            currentMonth = 0
                                            currentYear = model.year
                                            break
                                        case MetadataModels.TimelineQueryProvider.Day:
                                        default:
                                            metadataModel.queryProvider.startDate = buildDate(model.year, model.month, 1)
                                            metadataModel.queryProvider.endDate = buildDate(model.year, model.month+1, 1)

                                            currentMonth = model.month
                                            currentYear = model.year
                                            break
                                        }
                                        currentItem = null
                                        return
                                    }

                                    switch (metadataTimelineModel.queryProvider.level) {
                                    case MetadataModels.TimelineQueryProvider.Year:
                                        metadataModel.queryProvider.startDate = buildDate(model.year, 1, 1)
                                        metadataModel.queryProvider.endDate = buildDate(model.year, 12, 31)

                                        currentMonth = 0
                                        currentYear = model.year
                                        break
                                    case MetadataModels.TimelineQueryProvider.Month:
                                        metadataModel.queryProvider.startDate = buildDate(model.year, model.month, 1)
                                        metadataModel.queryProvider.endDate = buildDate(model.year, model.month+1, 1)

                                        currentMonth = model.month
                                        currentYear = model.year
                                        break
                                    case MetadataModels.TimelineQueryProvider.Day:
                                    default:
                                        metadataModel.queryProvider.startDate = buildDate(model.year, model.month, model.day)
                                        metadataModel.queryProvider.endDate = buildDate(model.year, model.month, model.day)

                                        currentMonth = model.month
                                        currentYear = model.year
                                        break
                                    }

                                    currentItem = dateDelegate
                                }
                            }
                        }
                    }
                }
            }
        }
    }


    PlasmaComponents.ToolButton {
        iconSource: "zoom-out"
        width: theme.largeIconSize
        height: width
        anchors {
            right: parent.right
            bottom: parent.bottom
            margins: 8
        }
        flat: false
        enabled: metadataTimelineModel.queryProvider.level != MetadataModels.TimelineQueryProvider.Year
        onClicked: {
            switch (metadataTimelineModel.queryProvider.level) {
            case MetadataModels.TimelineQueryProvider.Day:
                metadataTimelineModel.queryProvider.level = MetadataModels.TimelineQueryProvider.Month
                metadataTimelineModel.queryProvider.startDate = buildDate(currentYear, 1, 1)
                metadataTimelineModel.queryProvider.endDate = buildDate(currentYear, 12, 31)
                break
            case MetadataModels.TimelineQueryProvider.Month:
                metadataTimelineModel.queryProvider.level = MetadataModels.TimelineQueryProvider.Year
                var dat = new Date()
                metadataTimelineModel.queryProvider.startDate = ""
                metadataTimelineModel.queryProvider.endDate = ""
                break
            }
            currentItem = null
        }
    }
}
