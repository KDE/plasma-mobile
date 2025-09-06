// SPDX-FileCopyrightText: 2025 Seshan Ravikumar <seshan@sineware.ca>
// SPDX-License-Identifier: LGPL-2.0-or-later

import org.kde.plasma.private.mobileshell as MobileShell
import org.kde.plasma.private.mobileshell.quicksettingsplugin as QS
import org.kde.plasma.private.mobileshell.state as MobileShellState

QS.QuickSetting {
    text: i18n("Terminal")
    icon: "utilities-terminal-symbolic"
    status: i18n("Open terminal")
    enabled: false

    function toggle() {
        MobileShell.ShellUtil.launchApp("org.kde.qmlkonsole");
        MobileShellState.ShellDBusClient.closeActionDrawer();
    }
}