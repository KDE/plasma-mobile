/*
 *   Copyright 2011 Marco Martin <notmart@gmail.com>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 1.0
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.graphicswidgets 0.1 as PlasmaWidgets
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents
import org.kde.qtextracomponents 0.1

ListItem {
    id: notificationItem
    width: popupFlickable.width

    Column {
        spacing: 8
        width: popupFlickable.width
        Text {
            text: jobsSource.data[modelData]["appName"]
            font.bold: true
            color: theme.textColor
            anchors.horizontalCenter: parent.horizontalCenter
        }
        Grid {
            anchors {
                left: parent.left
                right: parent.right
            }
            spacing: 6
            rows: 2
            columns: 2

            Text {
                id: labelName0Text
                text: jobsSource.data[modelData]["labelName0"]
                width: Math.max(paintedWidth, labelName1Text.paintedWidth)
                horizontalAlignment: Text.AlignRight
            }
            Text {
                text: jobsSource.data[modelData]["label0"]
                width: parent.width - labelName0Text.width
                elide: Text.ElideMiddle
            }
            Text {
                id: labelName1Text
                text: jobsSource.data[modelData]["labelName1"]
                width: Math.max(paintedWidth, labelName0Text.paintedWidth)
                horizontalAlignment: Text.AlignRight
            }
            Text {
                text: jobsSource.data[modelData]["label1"]
                width: parent.width - labelName0Text.width
                elide: Text.ElideMiddle
            }
        }
        Row {
            spacing: 6
            anchors {
                left: parent.left
                right: parent.right
            }
            PlasmaWidgets.Meter {
                width: parent.width - 48 - 12
                height: 16
                meterType: "BarMeterHorizontal"
                svg: "widgets/bar_meter_horizontal"
                minimum: 0
                maximum: 100
                //percentage doesn't always exist, so doesn't get in the model
                value: jobsSource.data[modelData]["percentage"]
                anchors.verticalCenter: pauseButton.verticalCenter
            }
            MobileComponents.IconButton {
                id: pauseButton
                width: 22
                height: 22
                icon: jobsSource.data[modelData]["state"] == "suspended"?QIcon("media-playback-start"):QIcon("media-playback-pause")
                onClicked: {
                    var operationName = "suspend"
                    if (jobsSource.data[modelData]["state"] == "suspended") {
                        operationName = "resume"
                    }
                    var service = jobsSource.serviceForSource(modelData)
                    var operation = service.operationDescription(operationName)
                    service.startOperationCall(operation)
                }
            }
            MobileComponents.IconButton {
                id: stopButton
                width: 22
                height: 22
                icon: QIcon("media-playback-stop")
                onClicked: {
                    var service = jobsSource.serviceForSource(modelData)
                    var operation = service.operationDescription("stop")
                    service.startOperationCall(operation)
                }
            }
        }

        Item {
            anchors {
                left: parent.left
                right: parent.right
            }
            height: childrenRect.height
            //FIXME: proper localization
            Text {
                text: jobsSource.data[modelData]["processedAmount0"]+" "+jobsSource.data[modelData]["processedUnit0"]+"/"+jobsSource.data[modelData]["totalAmount0"]+" "+jobsSource.data[modelData]["totalUnit0"]
                anchors.left: parent.left
                color: theme.color
            }
            Text {
                text: jobsSource.data[modelData]["speed"]
                anchors.right: parent.right
                color: theme.color
            }
        }
    }
}
