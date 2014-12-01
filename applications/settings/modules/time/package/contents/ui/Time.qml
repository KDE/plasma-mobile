// -*- coding: iso-8859-1 -*-
/*
 *   Copyright 2011 Sebastian Kügler <sebas@kde.org>
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

import QtQuick 2.2
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.mobilecomponents 0.2 as MobileComponents
import org.kde.active.settings 2.0
import org.kde.active.settings.time 2.0

Item {
    id: timeModule
    objectName: "timeModule"

    TimeSettings {
        id: timeSettings
    }

    width: 800; height: 500

    MobileComponents.Package {
        id: timePackage
        name: "org.kde.active.settings.time"
    }

    Column {
        id: titleCol
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        PlasmaExtras.Title {
            text: settingsComponent.name
            opacity: 1
        }
        PlasmaComponents.Label {
            id: descriptionLabel
            text: settingsComponent.description
            opacity: .4
        }
    }

    Grid {
        id: formLayout
        columns: 2
        rows: 4
        spacing: theme.mSize(theme.defaultFont).height
        anchors {
            top: titleCol.bottom
            horizontalCenter: parent.horizontalCenter
            topMargin: theme.mSize(theme.defaultFont).height
        }

        PlasmaComponents.Label {
            text: i18n("Use 24-hour clock:")
            anchors {
                right: twentyFourSwitch.left
                rightMargin: theme.mSize(theme.defaultFont).width
            }
        }

        PlasmaComponents.Switch {
            id: twentyFourSwitch
            checked: timeSettings.twentyFour

            onClicked : {
                timeSettings.twentyFour = checked
                print(timeSettings.timeZone);
            }
        }


        PlasmaComponents.Label {
            id: timeZoneLabel
            text: i18n("Timezone:")
            anchors {
                right: timeZoneButton.left
                rightMargin: theme.mSize(theme.defaultFont).width
            }
        }

        PlasmaComponents.Button {
            id: timeZoneButton
            text: timeSettings.timeZone
            onClicked: timeZonePickerDialog.open()
        }

        PlasmaComponents.Label {
            id: ntpLabel
            text: i18n("Set time automatically:")
            anchors {
                right: timeZoneButton.left
                rightMargin: theme.mSize(theme.defaultFont).width
            }
        }

        Row {
            spacing: theme.mSize(theme.defaultFont).width
            PlasmaComponents.Switch {
                id: ntpCheckBox
                checked: timeSettings.ntpServer != ""
                onCheckedChanged: {
                    if (!checked) {
                        timeSettings.ntpServer = ""
                        timeSettings.saveTime()
                    }
                }
            }
            PlasmaComponents.Button {
                id: ntpButton
                text: timeSettings.ntpServer == "" ? i18n("Pick a server") : timeSettings.ntpServer
                onClicked: ntpServerPickerDialog.open()
                enabled: ntpCheckBox.checked
            }
        }


        MobileComponents.TimePicker {
            id: timePicker
            enabled: !ntpCheckBox.checked
            twentyFour: twentyFourSwitch.checked

            anchors {
                right: datePicker.left
                rightMargin: theme.mSize(theme.defaultFont).width
            }
            Component.onCompleted: {
                var date = new Date("January 1, 1971 "+timeSettings.currentTime)
                timePicker.hours = date.getHours()
                timePicker.minutes = date.getMinutes()
                timePicker.seconds = date.getSeconds()
            }
            Connections {
                target: timeSettings
                onCurrentTimeChanged: {
                    if (timePicker.userConfiguring) {
                        return
                    }

                    var date = new Date("January 1, 1971 "+timeSettings.currentTime)
                    timePicker.hours = date.getHours()
                    timePicker.minutes = date.getMinutes()
                    timePicker.seconds = date.getSeconds()
                }
            }
            onUserConfiguringChanged: {
                timeSettings.currentTime = timeString
                timeSettings.saveTime()
            }
        }

        MobileComponents.DatePicker {
            id: datePicker
            enabled: !ntpCheckBox.checked
            Component.onCompleted: {
                var date = new Date(timeSettings.currentDate)
                datePicker.day = date.getDate()
                datePicker.month = date.getMonth()+1
                datePicker.year = date.getFullYear()
            }
            Connections {
                target: timeSettings
                onCurrentDateChanged: {
                    if (datePicker.userConfiguring) {
                        return
                    }

                    var date = new Date(timeSettings.currentDate)

                    datePicker.day = date.getDate()
                    datePicker.month = date.getMonth()+1
                    datePicker.year = date.getFullYear()
                }
            }
            onUserConfiguringChanged: {
                timeSettings.currentDate = isoDate

                timeSettings.saveTime()
            }
        }
    }

    PlasmaComponents.CommonDialog {
        id: timeZonePickerDialog
        titleText: i18n("Timezones")
        buttonTexts: [i18n("Close")]
        onButtonClicked: close()
        content: Loader {
            id: timeZonePickerLoader
            width: theme.mSize(theme.defaultFont).width*22
            height: theme.mSize(theme.defaultFont).height*25
        }
        onStatusChanged: {
            if (status == PlasmaComponents.DialogStatus.Open) {
                timeZonePickerLoader.source = "TimeZonePicker.qml"
                timeZonePickerLoader.item.focusTextInput()
            }
        }
    }

    PlasmaComponents.SelectionDialog {
        id: ntpServerPickerDialog
        titleText: i18n("Pick a time server")
        selectedIndex: -1
        model: timeSettings.availableNtpServers
        delegate: PlasmaComponents.ListItem {
            enabled: true
            //visible: modelData.search(RegExp(filterField.filterText, "i")) != -1
            height: visible ? label.paintedHeight*2 : 0
            checked: timeSettings.ntpServer == modelData
            PlasmaComponents.Label {
                id: label
                anchors.verticalCenter: parent.verticalCenter
                text: modelData
            }
            onClicked: {
                timeSettings.ntpServer = modelData
                timeSettings.saveTime()
                ntpServerPickerDialog.close()
            }
        }
        onRejected: selectedIndex = -1
    }
}
