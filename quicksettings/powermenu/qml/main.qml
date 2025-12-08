/*
 *   SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

import org.kde.plasma.quicksetting.powermenu as PowerMenu
import org.kde.plasma.private.mobileshell.quicksettingsplugin as QS

QS.QuickSetting {
    text: i18n("Shut Down")
    icon: "system-shutdown-symbolic"
    status: i18n("Open power menu")
    enabled: false

    function toggle() {
        PowerMenu.PowerMenuUtil.openShutdownScreen();
    }
}

