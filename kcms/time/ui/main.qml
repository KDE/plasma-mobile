// -*- coding: iso-8859-1 -*-
/*
 *   SPDX-FileCopyrightText: 2011 Sebastian Kügler <sebas@kde.org>
 *   SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
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
                    checked = Qt.binding(function () { return kcm.twentyFour; });
                }
            }

            FormCard.FormDelegateSeparator { above: hourFormatSwitch; below: timeZoneSelect }

            FormCard.FormButtonDelegate {
                id: timeZoneSelect
                text: i18n("Timezone")
                description: kcm.timeZone
                onClicked: timeZonePickerDialog.open()
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
                    kcm.useNtp = checked;
                    checked = Qt.binding(function () { return kcm.useNtp; });
                }
            }

            FormCard.FormDelegateSeparator { above: ntpCheckBox; below: timeSelect }

            FormCard.FormButtonDelegate {
                id: timeSelect
                enabled: !ntpCheckBox.checked
                icon.name: "clock"
                text: i18n("System Time")
                description: Qt.formatTime(kcm.currentTime, kcm.twentyFour ? 'hh:mm' : 'hh:mm ap')
                onClicked: timePickerDialog.open()
            }

            FormCard.FormDelegateSeparator { above: timeSelect; below: dateSelect }

            FormCard.FormButtonDelegate {
                id: dateSelect
                text: i18n("System Date")
                description: Qt.formatDate(kcm.currentDate, Locale.LongFormat)
                icon.name: "view-calendar"
                enabled: !ntpCheckBox.checked
                onClicked: {
                    const component = Qt.createComponent("org.kde.kirigamiaddons.dateandtime", "DatePopup");
                    const dialog = component.createObject(timeModule.Controls.Overlay.overlay, {
                        modal: true,
                        value: kcm.currentDate,
                    });
                    dialog.x = Qt.binding(() => Math.round((timeModule.width - dialog.width) / 2));
                    dialog.y = Qt.binding(() => Math.round((timeModule.height - dialog.height) / 2));
                    dialog.accepted.connect(() => {
                        kcm.currentDate = dialog.value;
                        kcm.saveTime();
                    });
                    dialog.open();
                }
            }
        }
    }

    data: [
        Kirigami.Dialog {
            id: timeZonePickerDialog
            title: i18nc("@title:window", "Pick Timezone")
            standardButtons: Kirigami.Dialog.Ok | Kirigami.Dialog.Cancel

            property string selectedTimeZoneId

            onOpened: {
                selectedTimeZoneId = kcm.timeZone;
            }

            onAccepted: {
                kcm.saveTimeZone(selectedTimeZoneId)
            }

            ListView {
                id: listView
                currentIndex: -1 // otherwise the vkbd will constantly open and close while typing
                headerPositioning: ListView.OverlayHeader
                implicitWidth: 18 * Kirigami.Units.gridUnit
                implicitHeight: 18 * Kirigami.Units.gridUnit

                header: Controls.Control {
                    z: 1

                    topPadding: Kirigami.Units.smallSpacing
                    bottomPadding: 0
                    leftPadding: Kirigami.Units.smallSpacing
                    rightPadding: Kirigami.Units.smallSpacing

                    background: Rectangle {
                        color: Kirigami.Theme.backgroundColor
                    }

                    contentItem: ColumnLayout {
                        spacing: Kirigami.Units.smallSpacing
                        Kirigami.SearchField {
                            Layout.fillWidth: true
                            onTextChanged: kcm.timeZonesModel.filterString = text
                        }
                        Kirigami.Separator { Layout.fillWidth: true }
                    }
                }

                model: kcm.timeZonesModel
                delegate: Controls.RadioDelegate {
                    z: -1
                    width: ListView.view.width
                    checked: timeZonePickerDialog.selectedTimeZoneId == model.timeZoneId

                    text: {
                        if (model.region) {
                            return "%1 / %2".arg(model.region).arg(model.city);
                        } else {
                            return model.city;
                        }
                    }

                    onClicked: {
                        timeZonePickerDialog.selectedTimeZoneId = model.timeZoneId;
                        checked = Qt.binding(() => timeZonePickerDialog.selectedTimeZoneId == model.timeZoneId);
                        console.log(timeZonePickerDialog.selectedTimeZoneId + ' ' + model.timeZoneId + ' ' + (timeZonePickerDialog.selectedTimeZoneId == model.timeZoneId));
                    }
                }
            }
        },
        Kirigami.PromptDialog {
            id: timePickerDialog
            title: i18n("Pick System Time")
            preferredWidth: Kirigami.Units.gridUnit * 15
            standardButtons: Kirigami.Dialog.Save | Kirigami.Dialog.Cancel

            onAccepted: {
                kcm.currentTime = String(timePicker.hours).padStart(2, '0')
                    + ':'
                    + String(timePicker.minutes).padStart(2, '0')
                    + ':00';
                kcm.saveTime();
            }

            onOpened: {
                var date = new Date(kcm.currentTime);
                timePicker.hours = date.getHours();
                timePicker.minutes = date.getMinutes();
                console.log(date + ' ' + date.getHours() + date.getMinutes())
            }

            TimePicker {
                id: timePicker
                width: timePickerDialog.width - timePickerDialog.leftPadding - timePickerDialog.rightPadding

                Connections {
                    target: kcm
                    function onCurrentTimeChanged() {
                        if (timePicker.userConfiguring) {
                            return;
                        }

                        var date = new Date(kcm.currentTime);
                        timePicker.hours = date.getHours();
                        timePicker.minutes = date.getMinutes();
                    }
                }
            }
        }
    ]
}
