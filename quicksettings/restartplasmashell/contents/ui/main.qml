/*
 *   SPDX-FileCopyrightText: 2022 Yari Polla <skilvingr@gmail.com>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

import org.kde.plasma.private.mobileshell 1.0 as MobileShell

MobileShell.QuickSetting {
    text: i18n("Restart Shell")
    icon: "system-reboot"
    status: i18n("Tap to restart plasmashell")
    enabled: false
    
    function toggle() {
        MobileShell.ShellUtil.executeCommand('sh -c "killall plasmashell && plasmashell"');
    }
}

