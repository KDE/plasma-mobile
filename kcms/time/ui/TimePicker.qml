/*
    SPDX-FileCopyrightText: 2011 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick 2.1

import org.kde.kirigami 2.4 as Kirigami


//FIXME: shouldn't be a FrameSvgItem
Item {
    id: root
    clip: true

    //////// API
    property alias hours: clockRow.hours
    property alias minutes: clockRow.minutes
    property alias seconds: clockRow.seconds

    property bool userConfiguring: false
    property bool twentyFour: true

    property int fontSize: 14
    property int _margin: Kirigami.Units.gridUnit

    property string timeString: clockRow.twoDigitString(hours) + ":" + clockRow.twoDigitString(minutes) + ":" +  clockRow.twoDigitString(seconds)

    opacity: enabled ? 1.0 : 0.5

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
                //duration: PlasmaCore.Units.longDuration
                duration: 250
                easing.type: Easing.InOutQuad
            }
        }
    }

//     KLocale.Locale {
//         id: locale
//     }

    //imagePath: "widgets/picker"
    width: clockRow.width + root._margin
    height: clockRow.height + root._margin * 2

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

    Rectangle {
        color: "transparent"
        opacity: 0.3
        border.color: Kirigami.Theme.textColor
        border.width: 1
        anchors.fill: parent
    }

    Row {
        id: clockRow
        spacing: Kirigami.Units.gridUnit
        x: root._margin
        y: root._margin

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
                font.pointSize: root.fontSize
                color: Kirigami.Theme.textColor
                opacity: PathView.itemOpacity
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
        Kirigami.Separator {
            anchors {
                top: parent.top
                bottom: parent.bottom
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
        Kirigami.Separator {
            anchors {
                top: parent.top
                bottom: parent.bottom
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
        Kirigami.Separator {
            opacity: meridiaeDigit.opacity == 0 ? 0 : 1

            anchors {
                top: parent.top
                bottom: parent.bottom
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
                horizontalAlignment: Text.AlignLeft
                property int ownIndex: index
                text: meridiae
                color: Kirigami.Theme.textColor
                font.pointSize: root.fontSize
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
            width: meridiaePlaceHolder.width + root._margin
            Text {
                id: meridiaePlaceHolder
                visible: false
                font.pointSize: root.fontSize
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
