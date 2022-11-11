// SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick 2.15

import org.kde.plasma.private.mobileshell 1.0 as MobileShell

MobileShell.QuickSetting {
    property var batteryInfo: MobileShell.BatteryInfo {}
    
    text: i18n("Battery")
    status: i18n("%1%", batteryInfo.percent) 
    icon: "battery-full" + (batteryInfo.pluggedIn ? "-charging" : "")
    enabled: false
    settingsCommand: "plasma-open-settings kcm_mobile_power"
}
