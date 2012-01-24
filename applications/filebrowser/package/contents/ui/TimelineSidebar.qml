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
        color: theme.textColor
        width: 6
        anchors {
            top: parent.top
            bottom: parent.bottom
            topMargin: -parent.anchors.topMargin
            bottomMargin: -theme.defaultFont.mSize.width
        }
        x: timelineColumn.width/2 - 4
    }

    Item {
        id: timeline
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: backButton.top
            bottomMargin: 10
        }

        PlasmaComponents.Highlight {
            visible: currentItem != null
            width: timeline.width
            height: currentItem.height
            x: 0
            y: currentItem.y - timelineFlickable.contentY
        }
        Flickable {
            id: timelineFlickable
            anchors.fill: parent

            contentWidth: width
            contentHeight: timelineColumn.height


            Column {
                id: timelineColumn
                spacing: 40
                Repeater {
                    id: timelineRepeater
                    model: MetadataModels.MetadataTimelineModel {
                        id: metadataTimelineModel
                        level: MetadataModels.MetadataTimelineModel.Year
                        //queryString: "pdf"
                        resourceType: metadataModel.resourceType
                        tags: metadataModel.tags
                        minimumRating: metadataModel.minimumRating
                        //activityId: "12c8a6ea-c99b-4a54-bf42-a4e8fbcb9be7"
                        //startDate: "2011-01-01"
                        //endDate: "2011-12-31"
                    }

                    delegate: Rectangle {
                        id: dateDelegate
                        color: theme.textColor
                        width: 14 + 100 * (model.count / metadataTimelineModel.totalCount)
                        height: width
                        radius: width/2
                        anchors.horizontalCenter: parent.horizontalCenter
                        PlasmaComponents.Label {
                            text: model.label
                            anchors {
                                left: parent.horizontalCenter
                                leftMargin: timelineColumn.width/2
                                verticalCenter: parent.verticalCenter
                            }
                        }
                        MouseArea {
                            anchors {
                                fill: parent
                                rightMargin: - timelineFlickable.width + parent.width
                            }
                            onClicked: {
                                switch (metadataTimelineModel.level) {
                                case MetadataModels.MetadataTimelineModel.Year:
                                    metadataModel.startDate = buildDate(model.year, 1, 1)
                                    metadataModel.endDate = buildDate(model.year, 12, 31)

                                    currentMonth = 0
                                    currentYear = model.year
                                    break
                                case MetadataModels.MetadataTimelineModel.Month:
                                    metadataModel.startDate = buildDate(model.year, model.month, 1)
                                    metadataModel.endDate = buildDate(model.year, model.month, 31)

                                    currentMonth = model.month
                                    currentYear = model.year
                                    break
                                case MetadataModels.MetadataTimelineModel.Day:
                                default:
                                    metadataModel.startDate = buildDate(model.year, model.month, model.day)
                                    metadataModel.endDate = buildDate(model.year, model.month, model.day)

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
        PlasmaComponents.ScrollBar {
            flickableItem: timelineFlickable
            orientation: Qt.Vertical
        }
    }


    Column {
        anchors {
            top: parent.top
            right: parent.right
        }
        PlasmaComponents.ToolButton {
            iconSource: "zoom-in"
            width: theme.largeIconSize
            height: width
            flat: false
            enabled: metadataTimelineModel.level != MetadataModels.MetadataTimelineModel.Day
            onClicked: {
                switch (metadataTimelineModel.level) {
                case MetadataModels.MetadataTimelineModel.Year:
                    metadataTimelineModel.startDate = buildDate(currentYear, 1, 1)
                    metadataTimelineModel.endDate = buildDate(currentYear, 12, 31)
                    metadataTimelineModel.level = MetadataModels.MetadataTimelineModel.Month
                    break
                case MetadataModels.MetadataTimelineModel.Month:
                    metadataTimelineModel.startDate = buildDate(currentYear, currentMonth, 1)
                    metadataTimelineModel.endDate = buildDate(currentYear, currentMonth, 31)
                    metadataTimelineModel.level = MetadataModels.MetadataTimelineModel.Day
                    break
                }
                currentItem = null
            }
        }
        PlasmaComponents.ToolButton {
            iconSource: "zoom-out"
            width: theme.largeIconSize
            height: width
            flat: false
            enabled: metadataTimelineModel.level != MetadataModels.MetadataTimelineModel.Year
            onClicked: {
                switch (metadataTimelineModel.level) {
                case MetadataModels.MetadataTimelineModel.Day:
                    metadataTimelineModel.level = MetadataModels.MetadataTimelineModel.Month
                    metadataTimelineModel.startDate = buildDate(currentYear, 1, 1)
                    metadataTimelineModel.endDate = buildDate(currentYear, 12, 31)
                    break
                case MetadataModels.MetadataTimelineModel.Month:
                    metadataTimelineModel.level = MetadataModels.MetadataTimelineModel.Year
                    var dat = new Date()
                    metadataTimelineModel.startDate = ""
                    metadataTimelineModel.endDate = ""
                    break
                }
                currentItem = null
            }
        }
    }

    PlasmaComponents.Button {
        id: backButton
        anchors {
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
        }
        text: i18n("Back")
        onClicked: sidebarStack.pop()
    }
}
