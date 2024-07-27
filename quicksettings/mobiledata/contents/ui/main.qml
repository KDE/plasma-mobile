// SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick 2.15

import org.kde.plasma.mm as PlasmaMM
import org.kde.plasma.private.mobileshell as MobileShell
import org.kde.plasma.private.mobileshell.quicksettingsplugin as QS

QS.QuickSetting {
    text: i18n("Mobile Data")
    icon: "network-modem"
    status: {
        if (!PlasmaMM.SignalIndicator.modemAvailable) {
            return i18n("Not Available");
        } else if (PlasmaMM.SignalIndicator.needsAPNAdded) {
            return i18n("APN needs to be configured in the settings");
        } else if (PlasmaMM.SignalIndicator.mobileDataSupported) {
            return enabled ? i18n("On") : i18n("Off");
        } else if (PlasmaMM.SignalIndicator.simEmpty) {
            return i18n("No SIM inserted");
        } else {
            return i18n("Not Available");
        }
    }

    settingsCommand: "plasma-open-settings kcm_cellular_network"
    enabled: PlasmaMM.SignalIndicator.mobileDataEnabled

    function toggle() {
        if (PlasmaMM.SignalIndicator.needsAPNAdded || !PlasmaMM.SignalIndicator.mobileDataSupported) {
            // open settings if unable to toggle mobile data
            MobileShell.ShellUtil.executeCommand("plasma-open-settings kcm_cellular_network");
        } else {
            PlasmaMM.SignalIndicator.mobileDataEnabled = !PlasmaMM.SignalIndicator.mobileDataEnabled;
        }
    }
}
