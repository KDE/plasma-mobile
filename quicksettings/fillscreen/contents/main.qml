// SPDX-FileCopyrightText: 2025 Micah Stanley <stanleymicah@proton.me>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick 2.15

import org.kde.plasma.private.mobileshell.shellsettingsplugin as ShellSettings
import org.kde.plasma.private.mobileshell.quicksettingsplugin as QS

QS.QuickSetting {
    text: i18n("Fill Screen")
    icon: "view-fullscreen"
    enabled: ShellSettings.Settings.fillScreenModeEnabled

    function toggle() {
        ShellSettings.Settings.fillScreenModeEnabled = !ShellSettings.Settings.fillScreenModeEnabled;
    }
}