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

import QtQuick 2.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
//import org.kde.active.settings.time 2.0
//import "private"

//FIXME: shouldn't be a FrameSvgItem
PlasmaCore.FrameSvgItem {
    id: root
    clip: true

    //////// API
    property int day
    property int month
    property int year

    property bool userConfiguring: false

    property string isoDate: year + "-" + clockRow.twoDigitString(month) + "-" + clockRow.twoDigitString(day)


    /////// Implementation
    Connections {
        target: root
        onDayChanged: clockRow.day = root.day
        onMonthChanged: clockRow.month = root.month
        onYearChanged: clockRow.year = root.year
    }


    imagePath: "widgets/picker"
    width: clockRow.width + margins.left + margins.right
    height: clockRow.height + margins.top + margins.bottom


    Timer {
        id: userConfiguringTimer
        repeat: false
        interval: 1500
        running: false
        onTriggered: {
            root.day = clockRow.day
            root.month = clockRow.month
            root.year = clockRow.year
            userConfiguring = false
        }
    }

    Row {
        id: clockRow
        spacing: 3
        x: parent.margins.left
        y: parent.margins.top

        property int day
        property int month
        property int year

        function twoDigitString(number)
        {
            return number < 10 ? "0"+number : number
        }

        Digit {
            id: dayDigit
            model: {
                var dd = new Date(year, month, 0);
                return dd.getDate()
            }
            currentIndex: ((day - 1) < model) ? day-1 : 1
            onSelectedIndexChanged: {
                if (selectedIndex > -1) {
                    day = selectedIndex+1
                }
            }
            delegate: Text {
                horizontalAlignment: Text.AlignHCenter
                width: dayDigit.width
                property int ownIndex: index
                text: index+1
                font.pointSize: 20
                opacity: PathView.itemOpacity
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
            currentIndex: month -1
            onSelectedIndexChanged: {
                if (selectedIndex > -1) {
                    month = selectedIndex + 1
                }
            }
            delegate: Text {
                horizontalAlignment: Text.AlignHCenter
                width: monthDigit.width
                property int ownIndex: index
                property variant months: Array(i18n("Jan"), i18n("Feb"), i18n("Mar"), i18n("Apr"), i18n("May"),     i18n("Jun"), i18n("Jul"), i18n("Aug"), i18n("Sep"), i18n("Oct"), i18n("Nov"), i18n("Dec"))
                text: months[index]
                font.pointSize: 20
                opacity: PathView.itemOpacity
            }
            width: monthPlaceHolder.width
            Text {
                id: monthPlaceHolder
                visible: false
                font.pointSize: 20
                text: "0000"
            }
        }
        PlasmaCore.SvgItem {
            svg: PlasmaCore.Svg {imagePath: "widgets/line"}
            elementId: "vertical-line"
            width: naturalSize.width
            anchors {
                top: parent.top
                bottom: parent.bottom
            }
        }
        Digit {
            id: yearDigit
            //FIXME: yes, this is a tad lame ;)
            model: 3000
            currentIndex: year
            onSelectedIndexChanged: {
                if (selectedIndex > -1) {
                    year = selectedIndex
                }
            }
            width: yearPlaceHolder.width*1.3
            Text {
                id: yearPlaceHolder
                visible: false
                font.pointSize: 20
                text: "0000"
            }
        }
    }
}
