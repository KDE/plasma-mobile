// SPDX-FileCopyrightText: 2021-2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import org.kde.kcmutils
import org.kde.kirigami as Kirigami

Item {
    id: root
    implicitHeight: row.implicitHeight + Kirigami.Units.largeSpacing * 2

    property int hours: 0
    property int minutes: 0
    readonly property bool twelveHourTime: !kcm.twentyFour // am/pm

    onHoursChanged: updateHours()
    onMinutesChanged: minutesSpinbox.value = minutes
    onTwelveHourTimeChanged: updateHours()

    Component.onCompleted: {
        // needs to manually be triggered because onHoursChanged doesn't emit when set to 0
        updateHours();
    }

    function updateHours() {
        // manually do this instead of a binding so we can set the value without worrying about binding eval order
        hoursSpinbox.from = root.twelveHourTime ? 1 : 0;
        hoursSpinbox.to = root.twelveHourTime ? 12 : 23;

        if (twelveHourTime) {
            hoursSpinbox.value = ((hours % 12) == 0) ? 12 : hours % 12;
        } else {
            hoursSpinbox.value = hours;
        }
    }

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: Kirigami.Units.largeSpacing

        // note: for 12-hour time, we have hours from 1-12 (0'o clock displays as 12)
        //       for 24-hour time, we have hours from 0-23
        TimePickerSpinBox {
            id: hoursSpinbox

            onValueModified: {
                if (root.twelveHourTime) {
                    if (root.hours >= 12) {
                        root.hours = value % 12 + 12;
                    } else {
                        root.hours = value % 12;
                    }
                } else {
                    root.hours = value;
                }
            }
        }

        Kirigami.Heading {
            level: 1
            text: ":"
        }

        TimePickerSpinBox {
            id: minutesSpinbox
            from: 0
            to: 59

            onValueModified: {
                root.minutes = value;
            }
        }

        Button {
            id: amPmToggle
            visible: root.twelveHourTime
            leftPadding: Kirigami.Units.largeSpacing
            rightPadding: Kirigami.Units.largeSpacing
            topPadding: Kirigami.Units.largeSpacing
            bottomPadding: Kirigami.Units.largeSpacing
            Layout.alignment: Qt.AlignVCenter

            contentItem: Item {
                implicitWidth: label.implicitWidth
                implicitHeight: label.implicitHeight
                Label {
                    id: label
                    anchors.centerIn: parent
                    font.weight: Font.Light
                    font.pointSize: Kirigami.Theme.defaultFont.pointSize * 1.3
                    text: i18n(hours < 12 ? i18n("AM") : i18n("PM"))
                }
            }

            background: Rectangle {
                radius: Kirigami.Units.cornerRadius
                border.color: {
                    if (amPmToggle.enabled && (amPmToggle.visualFocus || amPmToggle.hovered || amPmToggle.down)) {
                        return Kirigami.Theme.focusColor
                    } else {
                        return Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.backgroundColor, Kirigami.Theme.textColor, 0.15)
                    }
                }
                border.width: 1
                color: amPmToggle.down ? Kirigami.Theme.alternateBackgroundColor : Kirigami.Theme.backgroundColor
            }

            onClicked: {
                if (root.hours >= 12) {
                    root.hours -= 12;
                } else {
                    root.hours += 12;
                }
            }
        }
    }
}
