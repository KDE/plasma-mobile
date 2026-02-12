// SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick 2.15

import org.kde.plasma.networkmanagement as PlasmaNM
import org.kde.plasma.private.mobileshell.quicksettingsplugin as QS
import org.kde.plasma.private.mobileshell as MobileShell

QS.QuickSetting {
    PlasmaNM.EnabledConnections {
        id: enabledConnections
    }

    text: i18n("Wi-Fi")
    status: enabledConnections.wirelessEnabled ? MobileShell.NetworkInfo.wirelessStatus.wifiSSID : ""
    icon: enabledConnections.wirelessEnabled ? "network-wireless" : "network-wireless-disconnected"
    settingsCommand: "plasma-open-settings kcm_mobile_wifi"
    enabled: enabledConnections.wirelessEnabled

    function toggle() {
        MobileShell.NetworkInfo.handler.enableWireless(!enabledConnections.wirelessEnabled);
    }
}
