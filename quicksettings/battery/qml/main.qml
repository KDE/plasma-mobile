// SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick 2.15

import org.kde.plasma.private.mobileshell.quicksettingsplugin as QS
import org.kde.plasma.private.mobileshell as MobileShell

QS.QuickSetting {
    text: i18n("Battery")
    status: i18n("%1%", MobileShell.BatteryInfo.percent)
    icon: "battery-full" + (MobileShell.BatteryInfo.pluggedIn ? "-charging" : "")
    enabled: false
    settingsCommand: "plasma-open-settings kcm_mobile_power"
}
