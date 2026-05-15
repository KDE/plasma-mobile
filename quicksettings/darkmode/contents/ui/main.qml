// SPDX-FileCopyrightText: 2026 Florian RICHER <florian.richer@protonmail.com>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick

import org.kde.plasma.private.mobileshell.quicksettingsplugin as QS
import org.kde.plasma.private.mobileshell as MobileShell

QS.QuickSetting {
    text: i18nc("@action:button", "Dark Mode")
    status: MobileShell.DarkModeControl.darkMode ? i18nc("@info:status", "On") : i18nc("@info:status", "Off")
    icon: "lighttable"

    enabled: MobileShell.DarkModeControl.darkMode

    function toggle(): void {
        MobileShell.DarkModeControl.darkMode = !MobileShell.DarkModeControl.darkMode;
    }
}
