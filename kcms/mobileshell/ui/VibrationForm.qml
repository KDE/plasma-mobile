/*
 * SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
 * SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2

import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import org.kde.kirigamiaddons.formcard 1 as FormCard
import org.kde.plasma.private.mobileshell.shellsettingsplugin as ShellSettings

FormCard.FormCardPage {
    id: root

    title: i18n("Shell Vibrations")

    FormCard.FormCard {
        Layout.topMargin: Kirigami.Units.gridUnit

        FormCard.FormSwitchDelegate {
            id: shellVibrationsSwitch
            text: i18n("Shell Vibrations")
            description: i18n("Whether to have vibrations enabled in the shell.")
            checked: ShellSettings.Settings.vibrationsEnabled
            onCheckedChanged: {
                if (checked != ShellSettings.Settings.vibrationsEnabled) {
                    ShellSettings.Settings.vibrationsEnabled = checked;
                }
            }
        }

        FormCard.FormDelegateSeparator { above: shellVibrationsSwitch; below: vibrationDurationDelegate }

        FormCard.FormComboBoxDelegate {
            id: vibrationDurationDelegate
            text: i18n("Vibration Duration")
            description: i18n("How long shell vibrations should be.")

            model: [
                {"name": i18nc("Long duration", "Long"), "value": 100},
                {"name": i18nc("Medium duration", "Medium"), "value": 50},
                {"name": i18nc("Short duration", "Short"), "value": 10}
            ]

            textRole: "name"
            valueRole: "value"

            Component.onCompleted: {
                currentIndex = indexOfValue(ShellSettings.Settings.vibrationDuration);
                dialog.parent = root;
            }
            onCurrentValueChanged: ShellSettings.Settings.vibrationDuration = currentValue;
        }
    }

    FormCard.FormSectionText {
        text: i18n("Keyboard vibrations are controlled separately in the keyboard settings module.")
    }
}
