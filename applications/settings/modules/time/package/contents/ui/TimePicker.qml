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
//import org.kde.locale 2.0 as KLocale
import org.kde.active.settings 2.0
//import org.kde.active.settings.time 2.0
//import "private"


//FIXME: shouldn't be a FrameSvgItem
PlasmaCore.FrameSvgItem {
    id: root
    clip: true

    //////// API
    property alias hours: clockRow.hours
    property alias minutes: clockRow.minutes
    property alias seconds: clockRow.seconds

    property bool userConfiguring: false
    property bool twentyFour: true

    property string timeString: clockRow.twoDigitString(hours) + ":" + clockRow.twoDigitString(minutes) + ":" +  clockRow.twoDigitString(seconds)

    Connections {
        target: root
//         onHoursChanged: print("H : " + root.hours)
//         onMinutesChanged: print("M : " + root.minutes)
//         onSecondsChanged: print("S : " + root.seconds)
    }

    Behavior on width {
        SequentialAnimation {
            PauseAnimation {
                duration: 250
            }
            NumberAnimation {
                //duration: units.longDuration
                duration: 250
                easing.type: Easing.InOutQuad
            }
        }
    }

//     KLocale.Locale {
//         id: locale
//     }

    imagePath: "widgets/picker"
    width: clockRow.width + margins.left + margins.right
    height: clockRow.height + margins.top + margins.bottom

    Timer {
        id: userConfiguringTimer
        repeat: false
        interval: 1500
        running: false
        onTriggered: {
            root.hours = clockRow.hours
            root.minutes = clockRow.minutes
            root.seconds = clockRow.seconds
            userConfiguring = false
        }
    }

    Row {
        id: clockRow
        spacing: 3
        x: parent.margins.left
        y: parent.margins.top

        property int hours
        property int minutes
        property int seconds

        function twoDigitString(number)
        {
            return number < 10 ? "0"+number : number
        }

        Digit {
            id: hoursDigit
            model: root.twentyFour ? 24 : 12
            currentIndex: root.twentyFour || hours < 12 ? hours : hours - 12
            delegate: Text {
                horizontalAlignment: Text.AlignHCenter
                width: hoursDigit.width
                property int ownIndex: index
                text: (!root.twentyFour && index == 0) ? "12" : clockRow.twoDigitString(index)
                font.pointSize: 20
                //opacity: PathView.itemOpacity
            }
            onSelectedIndexChanged: {
                print("Bah");
                if (selectedIndex > -1) {
                    if (root.twentyFour ||
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
            opacity: meridiaeDigit.opacity == 0 ? 0 : 1

            svg: PlasmaCore.Svg {imagePath: "widgets/line"}
            elementId: "vertical-line"
            width: naturalSize.width
            anchors {
                top: parent.top
                bottom:parent.bottom
            }
            Behavior on opacity {
                NumberAnimation {
                    duration: 250
                    easing.type: Easing.InOutQuad
                }
            }
        }
        Digit {
            id: meridiaeDigit
            visible: opacity != 0
            opacity: root.twentyFour ? 0 : 1
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
                width: meridiaeDigit.width
                horizontalAlignment: Text.AlignHCenter
                property int ownIndex: index
                text: meridiae
                font.pointSize: 20
                //opacity: PathView.itemOpacity
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
            width: meridiaePlaceHolder.width*1.3
            Text {
                id: meridiaePlaceHolder
                visible: false
                font.pointSize: 20
                text: "00"
            }
            Behavior on opacity {
                NumberAnimation {
                    duration: 250
                    easing.type: Easing.InOutQuad
                }
            }
        }
    }
}
