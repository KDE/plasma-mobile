// SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick 2.15

import org.kde.bluezqt 1.0 as BluezQt
import org.kde.plasma.private.mobileshell 1.0 as MobileShell

MobileShell.QuickSetting {
    text: i18n("Bluetooth")
    icon: "network-bluetooth"
    settingsCommand: "plasma-open-settings kcm_bluetooth"
    function toggle() {
        var enable = !BluezQt.Manager.bluetoothOperational;
        BluezQt.Manager.bluetoothBlocked = !enable;

        for (var i = 0; i < BluezQt.Manager.adapters.length; ++i) {
            var adapter = BluezQt.Manager.adapters[i];
            adapter.powered = enable;
        }
    }
    enabled: BluezQt.Manager.bluetoothOperational
}
