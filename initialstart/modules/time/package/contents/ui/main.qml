// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import org.kde.kirigami 2.20 as Kirigami
import org.kde.kirigamiaddons.formcard 1.0 as FormCard
import org.kde.plasma.mobileinitialstart.time as Time

Item {
    id: root
    property string name: i18n("Time and Date")

    readonly property real cardWidth: Math.min(Kirigami.Units.gridUnit * 30, root.width - Kirigami.Units.gridUnit * 2)

    ColumnLayout {
        anchors {
            fill: parent
            topMargin: Kirigami.Units.gridUnit
            bottomMargin: Kirigami.Units.gridUnit
        }

        width: root.width
        spacing: Kirigami.Units.gridUnit

        Label {
            Layout.leftMargin: Kirigami.Units.gridUnit
            Layout.rightMargin: Kirigami.Units.gridUnit
            Layout.alignment: Qt.AlignTop
            Layout.fillWidth: true

            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
            text: i18n("Select your time zone and preferred time format.")
        }

        FormCard.FormCard {
            maximumWidth: root.cardWidth

            Layout.alignment: Qt.AlignTop | Qt.AlignHCenter
            Layout.fillWidth: true

            FormCard.FormSwitchDelegate {
                Layout.fillWidth: true
                text: i18n("24-Hour Format")
                checked: Time.TimeUtil.is24HourTime
                onCheckedChanged: {
                    if (checked !== Time.TimeUtil.is24HourTime) {
                        Time.TimeUtil.is24HourTime = checked;
                    }
                }
            }
        }

        FormCard.FormCard {
            maximumWidth: root.cardWidth

            Layout.fillHeight: true
            Layout.alignment: Qt.AlignTop | Qt.AlignHCenter
            Layout.fillWidth: true

            ListView {
                id: listView

                clip: true
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: Time.TimeUtil.timeZones

                header: Control {
                    width: listView.width
                    leftPadding: Kirigami.Units.gridUnit
                    rightPadding: Kirigami.Units.gridUnit
                    topPadding: Kirigami.Units.gridUnit
                    bottomPadding: Kirigami.Units.gridUnit

                    contentItem: Kirigami.SearchField {
                        id: searchField

                        onTextChanged: {
                            Time.TimeUtil.timeZones.filterString = text;
                            // HACK: search field seems to lose focus every time the text changes
                            focusTimer.restart();
                        }

                        Timer {
                            id: focusTimer
                            interval: 1
                            onTriggered: searchField.forceActiveFocus()
                        }
                    }
                }

                delegate: FormCard.FormRadioDelegate {
                    required property string timeZoneId

                    width: ListView.view.width
                    text: timeZoneId
                    checked: Time.TimeUtil.currentTimeZone === timeZoneId
                    onCheckedChanged: {
                        if (checked && timeZoneId !== Time.TimeUtil.currentTimeZone) {
                            Time.TimeUtil.currentTimeZone = model.timeZoneId;
                            checked = Qt.binding(() => Time.TimeUtil.currentTimeZone === timeZoneId);
                        }
                    }
                }
            }
        }
    }
}

