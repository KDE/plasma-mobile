/*
 *   SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

import org.kde.plasma.private.mobileshell 1.0 as MobileShell
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.quicksetting.powermenu 1.0 as PowerMenu

MobileShell.QuickSetting {
    text: i18n("Shut Down")
    icon: "system-shutdown-symbolic"
    status: i18n("Open power menu")
    enabled: false
    
    function toggle() {
        PowerMenu.PowerMenuUtil.openShutdownScreen();
    }
}

