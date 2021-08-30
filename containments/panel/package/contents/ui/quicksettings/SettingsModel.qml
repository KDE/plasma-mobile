/*
 *   SPDX-FileCopyrightText: 2015 Marco Martin <notmart@gmail.com>
 *   SPDX-FileCopyrightText: 2021 Devin Lin <espidev@gmail.com>
 *   SPDX-FileCopyrightText: 2021 Aleix Pol Gonzalez <aleixpol@kde.org>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.14
import QtQuick.Layouts 1.1
import QtQuick.Window 2.2
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.networkmanagement 0.2 as PlasmaNM
import org.kde.bluezqt 1.0 as BluezQt
import org.kde.plasma.private.nanoshell 2.0 as NanoShell
import org.kde.plasma.private.mobilehomescreencomponents 0.1 as HomeScreenComponents

import org.kde.plasma.components 3.0 as PC3

HomeScreenComponents.QuickSettingsModel
{
    id: modelItem
    property bool screenshotRequested: false
    
    signal panelClosed()
    
    onPanelClosed: {
        if (screenshotRequested) {
            plasmoid.nativeInterface.takeScreenshot();
            screenshotRequested = false;
        }
    }

    HomeScreenComponents.QuickSetting {
        text: i18n("Settings")
        icon: "configure"
        enabled: false
        settingsCommand: "plasma-settings"
    }
    HomeScreenComponents.QuickSetting {
        PlasmaNM.Handler {
            id: nmHandler
        }

        PlasmaNM.EnabledConnections {
            id: enabledConnections
        }

        text: i18n("Wi-Fi")
        icon: "network-wireless-signal"
        settingsCommand: "plasma-settings -m kcm_mobile_wifi"
        function toggle() {
            nmHandler.enableWireless(!enabledConnections.wirelessEnabled)
        }
        enabled: enabledConnections.wirelessEnabled
    }
    HomeScreenComponents.QuickSetting {
        text: i18n("Bluetooth")
        icon: "network-bluetooth"
        settingsCommand: "plasma-settings -m kcm_bluetooth"
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
    HomeScreenComponents.QuickSetting {
        text: i18n("Mobile Data")
        icon: "network-modem"
        settingsCommand: "plasma-settings -m kcm_mobile_broadband"
        enabled: enabledConnections.wwanEnabled
        function toggle() {
            nmHandler.enableWwan(!enabledConnections.wwanEnabled)
        }
    }
    HomeScreenComponents.QuickSetting {
        text: i18n("Flashlight")
        icon: "flashlight-on"
        enabled: plasmoid.nativeInterface.torchEnabled
        function toggle() {
            plasmoid.nativeInterface.toggleTorch()
        }
    }
    HomeScreenComponents.QuickSetting {
        text: i18n("Location")
        icon: "gps"
        enabled: false
    }
    HomeScreenComponents.QuickSetting {
        text: i18n("Screenshot")
        icon: "spectacle"
        enabled: false
        function toggle() {
            modelItem.screenshotRequested = true;
            root.closeRequested();
        }
    }
    HomeScreenComponents.QuickSetting {
        text: i18n("Auto-rotate")
        icon: "rotation-allowed"
        enabled: plasmoid.nativeInterface.autoRotateEnabled
        function toggle() {
            plasmoid.nativeInterface.autoRotateEnabled = !enabled
        }
    }
}
