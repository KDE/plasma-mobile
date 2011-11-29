/*
 *   Copyright 2011 Marco Martin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2 or
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
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.components 0.1 as PlasmaComponents
//import org.kde.plasma.mobilecomponents 0.1 as MobileComponents
import org.kde.active.settings 0.1


PlasmaCore.FrameSvgItem {
    id: root
    clip: true

    Connections {
        target: timeSettings
        onCurrentDateChanged: {
            if (userConfiguring) {
                return
            }

            var date = new Date(timeSettings.currentDate)
            root.day = date.getDay()
            root.month = date.getMonth()
            root.year = date.getFullYear()
        }
    }
    Component.onCompleted: {
        if (userConfiguring) {
            return
        }

        var date = new Date(timeSettings.currentDate)
        root.day = date.getDay()
        root.month = date.getMonth()
        root.year = date.getFullYear()
    }


    property int day
    property int month
    property int year

    property bool userConfiguring: false

    imagePath: timePackage.filePath("images", "throbber.svgz")
    anchors {
        horizontalCenter: parent.horizontalCenter
    }
    width: clockRow.width + margins.left + margins.right
    height: clockRow.height + margins.top + margins.bottom


    Timer {
        id: userConfiguringTimer
        repeat: false
        interval: 1500
        running: false
        onTriggered: {
            var date = new Date(year, month, day, 0, 0, 0, 0)
            timeSettings.currentDate = year+"-"+clockRow.twoDigitString(month)+"-"+clockRow.twoDigitString(day)

            timeSettings.saveTime()
            userConfiguring = false
            yearDigit.selectedIndex = -1
            monthDigit.selectedIndex = -1
            dayDigit.selectedIndex = -1
        }
    }

    Row {
        id: clockRow
        spacing: 3
        x: parent.margins.left
        y: parent.margins.top

        function twoDigitString(number)
        {
            return number < 10 ? "0"+number : number
        }

        Digit {
            id: dayDigit
            model: 31
            currentIndex: day
            onSelectedIndexChanged: {
                if (selectedIndex > -1) {
                    year = selectedIndex
                }
            }
        }
        PlasmaCore.SvgItem {
            svg: PlasmaCore.Svg {imagePath: "widgets/line"}
            elementId: "vertical-line"
            width: naturalSize.width
            anchors {
                top: parent.top
                bottom:parent.bottom
            }
        }
        Digit {
            id: monthDigit
            model: 12
            currentIndex: month
            onSelectedIndexChanged: {
                if (selectedIndex > -1) {
                    month = selectedIndex
                }
            }
        }
        PlasmaCore.SvgItem {
            svg: PlasmaCore.Svg {imagePath: "widgets/line"}
            elementId: "vertical-line"
            width: naturalSize.width
            anchors {
                top: parent.top
                bottom:parent.bottom
            }
        }
        Digit {
            id: yearDigit
            model: year + 100
            currentIndex: year
            onSelectedIndexChanged: {
                if (selectedIndex > -1) {
                    year = selectedIndex
                }
            }
            width: yearPlaceHolder.width*1.1
            Text {
                id: yearPlaceHolder
                visible: false
                font.pointSize: 25
                text: "0000"
            }
        }
    }
}
