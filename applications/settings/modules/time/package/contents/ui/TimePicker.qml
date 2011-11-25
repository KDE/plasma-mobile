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

    Connections {
        target: timeSettings
        onCurrentTimeChanged: {
            if (userConfiguring) {
                return
            }

            var date = new Date("January 1, 1971 "+timeSettings.currentTime)
            root.hours = date.getHours()
            root.minutes = date.getMinutes()
            root.seconds = date.getSeconds()
        }
    }

    property int hours
    property int minutes
    property int seconds

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
            var date = new Date(1971, 1, 1, hours, minutes, seconds, 0)
            timeSettings.currentTime = clockRow.twoDigitString(hours)+":"+clockRow.twoDigitString(minutes)+":"+clockRow.twoDigitString(seconds)

            timeSettings.saveTime()
            userConfiguring = false
            hoursDigit.selectedIndex = -1
            minutesDigit.selectedIndex = -1
            secondsDigit.selectedIndex = -1
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
            id: hoursDigit
            model: timeSettings.twentyFour ? 24 : 12
            currentIndex: timeSettings.twentyFour || hours < 12 ? hours : hours - 12
            delegate: Text {
                property int ownIndex: index
                text: !timeSettings.twentyFour && index == 0 ? "12" : clockRow.twoDigitString(index)
                font.pointSize: 25
            }
            onSelectedIndexChanged: {
                if (selectedIndex > -1) {
                    if (timeSettings.twentyFour ||
                        meridiaeDigit.isAm) {
                        hours = selectedIndex
                    } else {
                        hours = selectedIndex + 12
                    }
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
            id: minutesDigit
            model: 60
            currentIndex: minutes
            onSelectedIndexChanged: {
                if (selectedIndex > -1) {
                    minutes = selectedIndex
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
            id: secondsDigit
            model: 60
            currentIndex: seconds
            onSelectedIndexChanged: {
                if (selectedIndex > -1) {
                    seconds = selectedIndex
                }
            }
        }
        PlasmaCore.SvgItem {
            visible: !timeSettings.twentyFour
            svg: PlasmaCore.Svg {imagePath: "widgets/line"}
            elementId: "vertical-line"
            width: naturalSize.width
            anchors {
                top: parent.top
                bottom:parent.bottom
            }
        }
        Digit {
            id: meridiaeDigit
            visible: !timeSettings.twentyFour
            property bool isAm: (selectedIndex > -1) ? (selectedIndex < 1) : (currentIndex < 1)
            model: ListModel {
                ListElement {
                    meridiae: "AM"
                }
                ListElement {
                    meridiae: "PM"
                }
            }
            delegate: Text {
                property int ownIndex: index
                text: meridiae
                font.pointSize: 25
            }
            currentIndex: hours > 12 ? 1 : 0
            onSelectedIndexChanged: {
                if (selectedIndex > -1) {
                    //AM
                    if (selectedIndex == 0) {
                        hours -= 12
                    //PM
                    } else {
                        hours += 12
                    }
                }
            }
        }
    }
}
