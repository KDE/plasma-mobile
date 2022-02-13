/*
 *   SPDX-FileCopyrightText: 2015 Marco Martin <notmart@gmail.com>
 *   SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 *   SPDX-FileCopyrightText: 2021 Aleix Pol Gonzalez <aleixpol@kde.org>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.14
import QtQuick.Layouts 1.1
import QtQuick.Window 2.2

import org.kde.bluezqt 1.0 as BluezQt

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PC3
import org.kde.plasma.networkmanagement 0.2 as PlasmaNM
import org.kde.plasma.mm 1.0 as PlasmaMM
import org.kde.plasma.private.mobileshell 1.0 as MobileShell

MobileShell.QuickSettingsModel {
    id: root
    
    required property var actionDrawer
    
    property bool screenshotRequested: false

    MobileShell.QuickSetting {
        text: i18n("Settings")
        status: i18n("Tap to open")
        icon: "configure"
        enabled: false
        settingsCommand: "plasma-open-settings"
    }
    
    MobileShell.QuickSetting {
        PlasmaNM.Handler {
            id: nmHandler
        }

        PlasmaNM.EnabledConnections {
            id: enabledConnections
        }

        text: i18n("Wi-Fi")
        icon: "network-wireless-signal"
        settingsCommand: "plasma-open-settings kcm_mobile_wifi"
        function toggle() {
            nmHandler.enableWireless(!enabledConnections.wirelessEnabled)
        }
        enabled: enabledConnections.wirelessEnabled
    }
    
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
    
    MobileShell.QuickSetting {
        text: i18n("Mobile Data")
        icon: "network-modem"
        settingsCommand: "plasma-open-settings kcm_mobile_broadband"
        enabled: PlasmaMM.SignalIndicator.mobileDataEnabled
        function toggle() {
            PlasmaMM.SignalIndicator.mobileDataEnabled = !PlasmaMM.SignalIndicator.mobileDataEnabled
        }
    }
    
    MobileShell.QuickSetting {
        text: i18n("Flashlight")
        icon: "flashlight-on"
        enabled: MobileShell.ShellUtil.torchEnabled
        function toggle() {
            MobileShell.ShellUtil.toggleTorch()
        }
    }
    
    MobileShell.QuickSetting {
        text: i18n("Location")
        icon: "gps"
        enabled: false
    }
    
    MobileShell.QuickSetting {
        text: i18n("Screenshot")
        status: i18n("Tap to screenshot")
        icon: "spectacle"
        enabled: false
        function toggle() {
            root.screenshotRequested = true;
            root.actionDrawer.close();
        }
        
        Connections {
            target: root.actionDrawer
            function onVisibleChanged(visible) {
                if (!visible && screenshotRequested) {
                    timer.restart();
                    root.screenshotRequested = false
                }
            }
        }
        
        // HACK: KWin's fade effect may have the window ending up being in the screenshot if taken too fast
        Timer {
            id: timer
            interval: 500
            onTriggered: MobileShell.ShellUtil.takeScreenshot()
        }
    }
    
    MobileShell.QuickSetting {
        text: i18n("Auto-rotate")
        icon: "rotation-allowed"
        settingsCommand: "plasma-open-settings kcm_kscreen"
        enabled: MobileShell.ShellUtil.autoRotateEnabled
        function toggle() {
            MobileShell.ShellUtil.autoRotateEnabled = !enabled
        }
    }
    
    MobileShell.QuickSetting {
        text: i18n("Battery")
        status: i18n("%1%", MobileShell.BatteryProvider.percent) 
        icon: "battery-full" + (MobileShell.BatteryProvider.pluggedIn ? "-charging" : "")
        enabled: false
        settingsCommand: "plasma-open-settings kcm_mobile_power"
    }
    
    MobileShell.QuickSetting {
        text: i18n("Sound")
        icon: "audio-speakers-symbolic"
        status: i18n("%1%", MobileShell.VolumeProvider.volumeValue) 
        enabled: false
        settingsCommand: "plasma-open-settings kcm_pulseaudio"
        function toggle() {
            volumeProvider.showVolumeOverlay()
        }
    }
}
