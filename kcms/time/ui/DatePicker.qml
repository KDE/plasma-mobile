/*
    SPDX-FileCopyrightText: 2011 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick 2.1
import org.kde.kirigami 2.5 as Kirigami
//import "private"

//FIXME: shouldn't be a FrameSvgItem
Item {
    id: root
    clip: true

    //////// API
    property int day
    property int month
    property int year

    property bool userConfiguring: false

    property string isoDate: year + "-" + clockRow.twoDigitString(month) + "-" + clockRow.twoDigitString(day)

    property int fontSize: 14
    property int _margin: Kirigami.Units.gridUnit

    opacity: enabled ? 1.0 : 0.5

    Rectangle {
        color: "transparent"
        border.width: 1
        border.color: Kirigami.Theme.textColor
        anchors.fill: parent
        opacity: 0.3
    }

    /////// Implementation
    Connections {
        target: root
        onDayChanged: clockRow.day = root.day
        onMonthChanged: clockRow.month = root.month
        onYearChanged: clockRow.year = root.year
    }


    //imagePath: "widgets/picker"
    width: clockRow.width + root._margin * 2
    height: clockRow.height + root._margin * 2


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
        x: root._margin
        y: root._margin

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
                color: Kirigami.Theme.textColor
                font.pointSize: root.fontSize
                opacity: PathView.itemOpacity
            }
        }
        Kirigami.Separator {
            anchors {
                top: parent.top
                bottom: parent.bottom
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
                font.pointSize: root.fontSize
                color: Kirigami.Theme.textColor
                opacity: PathView.itemOpacity
            }
            width: monthPlaceHolder.width
            Text {
                id: monthPlaceHolder
                visible: false
                font.pointSize: root.fontSize
                text: "0000"
            }
        }
        Kirigami.Separator {
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
                font.pointSize: root.fontSize
                text: "0000"
            }
        }
    }
}
