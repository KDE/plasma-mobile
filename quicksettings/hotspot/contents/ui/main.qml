// SPDX-FileCopyrightText: 2022 Yari Polla <skilvingr@gmail.com>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick 2.15

import org.kde.plasma.private.mobileshell.quicksettingsplugin as QS
import org.kde.plasma.private.mobileshell as MobileShell

QS.QuickSetting {
    id: root

    text: i18n("Hotspot")
    icon: "network-wireless-hotspot"

    enabled: MobileShell.NetworkInfo.wirelessStatus.hotspotSSID.length !== 0
    status: enabled ? MobileShell.NetworkInfo.wirelessStatus.hotspotSSID : ""

    settingsCommand: "plasma-open-settings kcm_mobile_hotspot"
    function toggle() {
        if (!enabled) {
            MobileShell.NetworkInfo.handler.createHotspot();
        } else {
            MobileShell.NetworkInfo.handler.stopHotspot();
        }
    }
}
