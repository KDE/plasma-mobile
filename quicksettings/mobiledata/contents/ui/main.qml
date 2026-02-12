// SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick 2.15

import org.kde.plasma.networkmanagement.cellular as Cellular
import org.kde.plasma.private.mobileshell as MobileShell
import org.kde.plasma.private.mobileshell.quicksettingsplugin as QS

QS.QuickSetting {
    id: root

    Cellular.CellularModemList {
        id: modemList
    }

    property Cellular.CellularModem modem: modemList.primaryModem

    text: i18n("Mobile Data")
    icon: "network-modem"
    status: {
        if (!modemList.modemAvailable) {
            return i18n("Not Available");
        } else if (modem.needsAPNAdded) {
            return i18n("APN needs to be configured in the settings");
        } else if (modem.mobileDataSupported) {
            return enabled ? i18n("On") : i18n("Off");
        } else if (modem.simEmpty) {
            return i18n("No SIM inserted");
        } else {
            return i18n("Not Available");
        }
    }

    settingsCommand: "plasma-open-settings kcm_cellular_network"
    enabled: modem ? modem.mobileDataEnabled : false

    function toggle() {
        if (!modem || modem.needsAPNAdded || !modem.mobileDataSupported) {
            // open settings if unable to toggle mobile data
            MobileShell.ShellUtil.executeCommand("plasma-open-settings kcm_cellular_network");
        } else {
            modem.mobileDataEnabled = !modem.mobileDataEnabled;
        }
    }
}
