/*
 *   SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import org.kde.plasma.private.mobileshell.state as MobileShellState
import org.kde.plasma.private.mobileshell.quicksettingsplugin as QS

QS.QuickSetting {
    text: i18n("Do Not Disturb")
    icon: enabled ? "notifications-disabled" : "notifications"
    status: ""
    enabled: MobileShellState.ShellDBusClient.doNotDisturb

    function toggle() {
        MobileShellState.ShellDBusClient.doNotDisturb = !MobileShellState.ShellDBusClient.doNotDisturb;
    }
}
