// -*- coding: iso-8859-1 -*-
/*
 *   SPDX-FileCopyrightText: 2011 Sebastian Kügler <sebas@kde.org>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3 as Controls

import org.kde.kirigami 2.10 as Kirigami
import org.kde.kcm 1.2
import org.kde.timesettings 1.0
import org.kde.kirigamiaddons.labs.mobileform 0.1 as MobileForm

SimpleKCM {
    id: timeModule

    leftPadding: 0
    rightPadding: 0
    topPadding: Kirigami.Units.gridUnit
    bottomPadding: Kirigami.Units.gridUnit
    
    Component {
        id: listDelegateComponent

        Kirigami.BasicListItem {
            text: {
                if (model) {
                    if (model.region) {
                        return "%1 / %2".arg(model.region).arg(model.city)
                    } else {
                        return model.city
                    }
                }
                return ""
            }
            onClicked: {
                timeZonePickerSheet.close()
                kcm.saveTimeZone(model.timeZoneId)
            }
        }
    }

    ColumnLayout {
        spacing: 0
        width: parent.width
        
        MobileForm.FormCard {
            Layout.fillWidth: true
            
            contentItem: ColumnLayout {
                spacing: 0
                
                MobileForm.FormCardHeader {
                    title: i18n("Display")
                }

                MobileForm.FormSwitchDelegate {
                    id: hourFormatSwitch
                    text: i18n("24-Hour Format")
                    description: i18n("Whether to use a 24-hour format for clocks.")
                    checked: kcm.twentyFour
                    onCheckedChanged: {
                        kcm.twentyFour = checked
                    }
                }
                
                MobileForm.FormDelegateSeparator { above: hourFormatSwitch; below: timeZoneSelect }
                
                MobileForm.FormButtonDelegate {
                    id: timeZoneSelect
                    text: i18n("Timezone")
                    description: kcm.timeZone
                    onClicked: timeZonePickerSheet.open()
                }
            }
        }
        
        MobileForm.FormCard {
            Layout.topMargin: Kirigami.Units.largeSpacing
            Layout.fillWidth: true
            
            contentItem: ColumnLayout {
                spacing: 0
                
                MobileForm.FormCardHeader {
                    title: i18n("Time and Date")
                }

                MobileForm.FormSwitchDelegate {
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
                
                MobileForm.FormDelegateSeparator { above: ntpCheckBox; below: timeSelect }
                
                MobileForm.FormButtonDelegate {
                    id: timeSelect
                    enabled: !ntpCheckBox.checked
                    icon.name: "clock"
                    text: i18n("Current Time")
                    description: Qt.formatTime(kcm.currentTime, Locale.LongFormat)
                    onClicked: timePickerSheet.open()
                }
                
                MobileForm.FormDelegateSeparator { above: timeSelect; below: dateSelect }
                
                MobileForm.FormButtonDelegate {
                    id: dateSelect
                    enabled: !ntpCheckBox.checked
                    icon.name: "view-calendar"
                    text: i18n("Date")
                    description: Qt.formatDate(kcm.currentDate, Locale.LongFormat)
                    onClicked: datePickerSheet.open()
                }
            }
        }
    }

    Kirigami.OverlaySheet {
        id: timeZonePickerSheet
        header: ColumnLayout {
            Kirigami.Heading {
                text: i18nc("@title:window", "Pick Timezone")
            }
            Kirigami.SearchField {
                Layout.fillWidth: true
                width: parent.width
                onTextChanged: {
                    kcm.timeZonesModel.filterString = text
                }
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
            clip: true
            anchors.fill: parent
            implicitWidth: 18 * Kirigami.Units.gridUnit
            model: kcm.timeZonesModel
            delegate: Kirigami.DelegateRecycler {
                width: parent.width

                sourceComponent: listDelegateComponent
            }
        }
    }

    Kirigami.OverlaySheet {
        id: timePickerSheet
        header:  Kirigami.Heading { text: i18n("Pick Time") }
        TimePicker {
            id: timePicker
            enabled: !ntpCheckBox.checked
            twentyFour: twentyFourSwitch.checked

            implicitWidth: width > Kirigami.Units.gridUnit * 15 ? width : Kirigami.Units.gridUnit * 15

            Component.onCompleted: {
                var date = new Date(kcm.currentTime);
                timePicker.hours = date.getHours();
                timePicker.minutes = date.getMinutes();
                timePicker.seconds = date.getSeconds();
            }
            Connections {
                target: kcm
                onCurrentTimeChanged: {
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
                onCurrentDateChanged: {
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
