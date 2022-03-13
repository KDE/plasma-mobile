// SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick 2.15

import org.kde.plasma.mm 1.0 as PlasmaMM
import org.kde.plasma.private.mobileshell 1.0 as MobileShell

MobileShell.QuickSetting {
    text: i18n("Mobile Data")
    icon: "network-modem"
    status: PlasmaMM.SignalIndicator.mobileDataSupported 
                ? (enabled ? i18n("On") : i18n("Off"))
                : i18n("Not Available")
    settingsCommand: "plasma-open-settings kcm_mobile_broadband"
    enabled: PlasmaMM.SignalIndicator.mobileDataEnabled
    function toggle() {
        PlasmaMM.SignalIndicator.mobileDataEnabled = !PlasmaMM.SignalIndicator.mobileDataEnabled
    }
}
