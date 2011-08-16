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
import org.kde.qtextracomponents 0.1

ListItem {
    id: notificationItem
    width: popupFlickable.width

    Column {
        spacing: 8
        width: popupFlickable.width
        Text {
            text: appName
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
                text: labelName0
                width: Math.max(paintedWidth, labelName1Text.paintedWidth)
                horizontalAlignment: Text.AlignRight
            }
            Text {
                text: label0
                width: parent.width - labelName0Text.width
                elide: Text.ElideMiddle
            }
            Text {
                id: labelName1Text
                text: labelName1
                width: Math.max(paintedWidth, labelName0Text.paintedWidth)
                horizontalAlignment: Text.AlignRight
            }
            Text {
                text: label1
                width: parent.width - labelName0Text.width
                elide: Text.ElideMiddle
            }
        }
        PlasmaWidgets.Meter {
            anchors {
                left: parent.left
                right: parent.right
            }
            height: 16
            meterType: "BarMeterHorizontal"
            svg: "widgets/bar_meter_horizontal"
        }
    }
}
