// SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick 2.15

import org.kde.plasma.private.mobileshell.shellsettingsplugin as ShellSettings
import org.kde.plasma.private.mobileshell.hapticsplugin as HapticsPlugin

QtObject {
    function buttonVibrate() {
        if (ShellSettings.Settings.vibrationsEnabled) {
            HapticsPlugin.VibrationManager.vibrate(ShellSettings.Settings.vibrationDuration);
        }
    }
}

