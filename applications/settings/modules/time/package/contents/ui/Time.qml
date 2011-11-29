// -*- coding: iso-8859-1 -*-
/*
 *   Copyright 2011 Sebastian Kügler <mart@kde.org>
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
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents
import org.kde.active.settings 0.1

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
        spacing: 12
        Text {
            color: theme.textColor
            text: "<h3>" + moduleTitle + "</h3>"
            opacity: 1
        }
        Text {
            id: descriptionLabel
            color: theme.textColor
            text: moduleDescription
            opacity: .4
        }
    }

    Grid {
        id: formLayout
        columns: 2
        rows: 3
        spacing: theme.defaultFont.mSize.height
        anchors {
            top: titleCol.bottom
            horizontalCenter: parent.horizontalCenter
            topMargin: theme.defaultFont.mSize.height*3
        }

        PlasmaComponents.Label {
            text: i18n("Use 24-hour clock:")
            anchors {
                right: twentyFourSwitch.left
                rightMargin: theme.defaultFont.mSize.width
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
                rightMargin: theme.defaultFont.mSize.width
            }
        }

        PlasmaComponents.Button {
            id: timeZoneButton
            text: timeSettings.timeZone
            onClicked: timeZonePickerDialog.open()
        }

        PlasmaComponents.Label {
            id: ntpLabel
            text: i18n("Use NTP:")
            anchors {
                right: timeZoneButton.left
                rightMargin: theme.defaultFont.mSize.width
            }
        }

        Row {
            spacing: theme.defaultFont.mSize.width
            PlasmaComponents.CheckBox {
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
    }


    Column {
        anchors {
            top: formLayout.bottom
            topMargin: theme.defaultFont.mSize.height*3
            horizontalCenter: parent.horizontalCenter
        }
        spacing: 32
        TimePicker {
            enabled: !ntpCheckBox.checked
            anchors.horizontalCenter: parent.horizontalCenter
        }
        DatePicker {
            enabled: !ntpCheckBox.checked
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    PlasmaComponents.CommonDialog {
        id: timeZonePickerDialog
        titleText: i18n("Timezones")
        buttonTexts: [i18n("Close")]
        onButtonClicked: close()
        content: Loader {
            id: timeZonePickerLoader
            width: theme.defaultFont.mSize.width*22
            height: theme.defaultFont.mSize.height*25
        }
        onStatusChanged: {
            if (status == PlasmaComponents.DialogStatus.Open) {
                timeZonePickerLoader.source = "TimeZonePicker.qml"
            }
        }
    }

    PlasmaComponents.SelectionDialog {
        id: ntpServerPickerDialog
        titleText: i18n("Pick a time server")
        selectedIndex: -1
        model: timeSettings.availableNtpServers
        delegate: PlasmaComponents.Label {
            visible: modelData.search(RegExp(filterField.text, "i")) != -1
            height: visible ? paintedHeight : 0
            text: modelData
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    timeSettings.ntpServer = modelData
                    timeSettings.saveTime()
                    ntpServerPickerDialog.close()
                }
            }
        }

        onRejected: selectedIndex = -1
    }

}
