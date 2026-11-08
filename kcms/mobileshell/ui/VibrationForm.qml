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

        FormCard.FormSpinBoxDelegate {
            id: vibrationDurationDelegate
            label: i18n("Vibration duration (ms)")
            description: i18n("How long shell vibrations should be.")
            enabled: ShellSettings.Settings.vibrationsEnabled

            from: 1
            to: 200
            value: ShellSettings.Settings.vibrationDuration

            onValueModified: ShellSettings.Settings.vibrationDuration = value
        }

        FormCard.FormDelegateSeparator { above: vibrationDurationDelegate; below: resetDurationButton }

        FormCard.FormButtonDelegate {
            id: resetDurationButton
            icon.name: "edit-reset"
            text: i18n("Reset to default duration")
            enabled: ShellSettings.Settings.vibrationsEnabled
            onClicked: {
                ShellSettings.Settings.resetVibrationDuration();
                vibrationDurationDelegate.value = Qt.binding(() => ShellSettings.Settings.vibrationDuration);
            }
        }
    }

    FormCard.FormSectionText {
        text: i18n("Keyboard vibrations are controlled separately in the keyboard settings module.")
    }
}
