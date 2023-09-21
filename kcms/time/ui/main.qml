// -*- coding: iso-8859-1 -*-
/*
 *   SPDX-FileCopyrightText: 2011 Sebastian Kügler <sebas@kde.org>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls

import org.kde.kirigami as Kirigami
import org.kde.kcmutils
import org.kde.timesettings
import org.kde.kirigamiaddons.formcard 1 as FormCard
import org.kde.kirigamiaddons.delegates 1 as Delegates

SimpleKCM {
    id: timeModule

    leftPadding: 0
    rightPadding: 0
    topPadding: 0
    bottomPadding: 0

    ColumnLayout {
        spacing: 0

        FormCard.FormHeader {
            title: i18n("Display")
        }

        FormCard.FormCard {
            FormCard.FormSwitchDelegate {
                id: hourFormatSwitch
                text: i18n("24-Hour Format")
                description: i18n("Whether to use a 24-hour format for clocks.")
                checked: kcm.twentyFour
                onCheckedChanged: {
                    kcm.twentyFour = checked
                }
            }

            FormCard.FormDelegateSeparator { above: hourFormatSwitch; below: timeZoneSelect }

            FormCard.FormButtonDelegate {
                id: timeZoneSelect
                text: i18n("Timezone")
                description: kcm.timeZone
                onClicked: timeZonePickerSheet.open()
            }
        }

        FormCard.FormHeader {
            title: i18n("Time and Date")
        }

        FormCard.FormCard {
            FormCard.FormSwitchDelegate {
                id: ntpCheckBox
                text: i18n("Automatic Time Synchronization")
                description: i18n("Whether to set the time automatically.")
                checked: kcm.useNtp
                onCheckedChanged: {
                    kcm.useNtp = checked
                    if (!checked) {
                        kcm.ntpServer = ""
                        kcm.saveTime()
                    }
                }
            }

            FormCard.FormDelegateSeparator { above: ntpCheckBox; below: timeSelect }

            FormCard.FormButtonDelegate {
                id: timeSelect
                enabled: !ntpCheckBox.checked
                icon.name: "clock"
                text: i18n("Current Time")
                description: Qt.formatTime(kcm.currentTime, Locale.LongFormat)
                onClicked: timePickerSheet.open()
            }

            FormCard.FormDelegateSeparator { above: timeSelect; below: dateSelect }

            FormCard.FormButtonDelegate {
                id: dateSelect
                enabled: !ntpCheckBox.checked
                icon.name: "view-calendar"
                text: i18n("Date")
                description: Qt.formatDate(kcm.currentDate, Locale.LongFormat)
                onClicked: datePickerSheet.open()
            }
        }
    }

    data: Kirigami.OverlaySheet {
        id: timeZonePickerSheet

        header: ColumnLayout {
            Kirigami.Heading {
                text: i18nc("@title:window", "Pick Timezone")
                Layout.fillWidth: true
            }

            Kirigami.SearchField {
                Layout.fillWidth: true
                onTextChanged: kcm.timeZonesModel.filterString = text
            }
        }

        footer: RowLayout {
            Controls.Button {
                Layout.alignment: Qt.AlignHCenter

                text: i18nc("@action:button", "Close")

                onClicked: timeZonePickerSheet.close()
            }
        }

        ListView {
            id: listView

            clip: true
            implicitWidth: 18 * Kirigami.Units.gridUnit

            topMargin: Math.round(Kirigami.Units.smallSpacing / 2)
            bottomMargin: Math.round(Kirigami.Units.smallSpacing / 2)

            model: kcm.timeZonesModel
            delegate: Delegates.RoundedItemDelegate {
                required property string region
                required property string city

                width: ListView.view.width

                text: {
                    if (region) {
                        return "%1 / %2".arg(region).arg(city)
                    } else {
                        return city
                    }
                }

                onClicked: {
                    timeZonePickerSheet.close()
                    kcm.saveTimeZone(model.timeZoneId)
                }
            }
        }
    }

    Kirigami.OverlaySheet {
        id: timePickerSheet
        header:  Kirigami.Heading { text: i18n("Pick Time") }
        TimePicker {
            id: timePicker
            enabled: !ntpCheckBox.checked
            twentyFour: hourFormatSwitch.checked

            implicitWidth: Kirigami.Units.gridUnit * 15

            Component.onCompleted: {
                var date = new Date(kcm.currentTime);
                timePicker.hours = date.getHours();
                timePicker.minutes = date.getMinutes();
                timePicker.seconds = date.getSeconds();
            }
            Connections {
                target: kcm
                function onCurrentTimeChanged() {
                    if (timePicker.userConfiguring) {
                        return;
                    }

                    var date = new Date(kcm.currentTime);
                    timePicker.hours = date.getHours();
                    timePicker.minutes = date.getMinutes();
                    timePicker.seconds = date.getSeconds();
                }
            }
            onUserConfiguringChanged: {
                kcm.currentTime = timeString
                kcm.saveTime()
            }
        }
        footer: RowLayout {
            Controls.Button {
                Layout.alignment: Qt.AlignRight

                text: i18nc("@action:button", "Close")

                onClicked: timePickerSheet.close()
            }
        }
    }

    Kirigami.OverlaySheet {
        id: datePickerSheet
        header: Kirigami.Heading { text: i18n("Pick Date") }
        DatePicker {
            id: datePicker
            enabled: !ntpCheckBox.checked

            implicitWidth: width > Kirigami.Units.gridUnit * 15 ? width : Kirigami.Units.gridUnit * 15

            Component.onCompleted: {
                var date = new Date(kcm.currentDate)
                datePicker.day = date.getDate()
                datePicker.month = date.getMonth()+1
                datePicker.year = date.getFullYear()
            }
            Connections {
                target: kcm
                function onCurrentDateChanged() {
                    if (datePicker.userConfiguring) {
                        return
                    }

                    var date = new Date(kcm.currentDate)

                    datePicker.day = date.getDate()
                    datePicker.month = date.getMonth()+1
                    datePicker.year = date.getFullYear()
                }
            }
            onUserConfiguringChanged: {
                kcm.currentDate = isoDate
                kcm.saveTime()
            }
        }
        footer: RowLayout {
            Controls.Button {
                Layout.alignment: Qt.AlignRight

                text: i18nc("@action:button", "Close")

                onClicked: datePickerSheet.close()
            }
        }
    }
}
