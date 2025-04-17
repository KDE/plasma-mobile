// SPDX-FileCopyrightText: 2025 Micah Stanley <stanleymicah@proton.me>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick

import org.kde.plasma.private.mobileshell.shellsettingsplugin as ShellSettings
import org.kde.plasma.private.mobileshell.quicksettingsplugin as QS

QS.QuickSetting {
    text: i18n("Auto Hide Panels")
    icon: "view-fullscreen"
    enabled: ShellSettings.Settings.autoHidePanelsEnabled

    function toggle() {
        ShellSettings.Settings.autoHidePanelsEnabled = !ShellSettings.Settings.autoHidePanelsEnabled;
    }
}