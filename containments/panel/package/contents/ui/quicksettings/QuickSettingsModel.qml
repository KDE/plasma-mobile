/*
 *   SPDX-FileCopyrightText: 2015 Marco Martin <notmart@gmail.com>
 *   SPDX-FileCopyrightText: 2021 Devin Lin <espidev@gmail.com>
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
import org.kde.colorcorrect 0.1 as CC
import org.kde.plasma.private.nanoshell 2.0 as NanoShell

import org.kde.plasma.components 3.0 as PC3

Item {
    id: modelItem
    property bool screenshotRequested: false
    
    signal panelClosed()
    
    onPanelClosed: {
        if (screenshotRequested) {
            plasmoid.nativeInterface.takeScreenshot();
            screenshotRequested = false;
        }
    }
    
    readonly property list<QuickSetting> model: [
        QuickSetting {
            text: i18n("Settings")
            icon: "configure"
            enabled: false
            settingsCommand: "plasma-settings"
        },
        QuickSetting {
            text: i18n("Wifi")
            icon: "network-wireless-signal"
            settingsCommand: "plasma-settings -m kcm_mobile_wifi"
            function toggle() {
                nmHandler.enableWireless(!enabledConnections.wirelessEnabled)
            }
            enabled: enabledConnections.wirelessEnabled
        },
        QuickSetting {
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
        },
        QuickSetting {
            text: i18n("Mobile Data")
            icon: "network-modem"
            settingsCommand: "plasma-settings -m kcm_mobile_broadband"
            enabled: enabledConnections.wwanEnabled
            function toggle() {
                nmHandler.enableWwan(!enabledConnections.wwanEnabled)
            }
        },
        QuickSetting {
            text: i18n("Battery")
            icon: "battery-full"
            enabled: false
            settingsCommand: "plasma-settings -m kcm_mobile_power"
        },
        QuickSetting {
            text: i18n("Sound")
            icon: "audio-speakers-symbolic"
            enabled: false
            settingsCommand: "plasma-settings -m kcm_pulseaudio"
            function toggle() {
                volumeProvider.showVolumeOverlay()
            }
        },
        QuickSetting {
            text: i18n("Flashlight")
            icon: "flashlight-on"
            enabled: plasmoid.nativeInterface.torchEnabled
            function toggle() {
                plasmoid.nativeInterface.toggleTorch()
            }
        },
        QuickSetting {
            text: i18n("Location")
            icon: "gps"
            enabled: false
        },
        QuickSetting {
            text: i18n("Screenshot")
            icon: "spectacle"
            enabled: false
            function toggle() {
                modelItem.screenshotRequested = true;
                root.closeRequested();
            }
        },
        QuickSetting {
            text: i18n("Auto-rotate")
            icon: "rotation-allowed"
            enabled: plasmoid.nativeInterface.autoRotateEnabled
            function toggle() {
                plasmoid.nativeInterface.autoRotateEnabled = !enabled
            }
        },
        QuickSetting {
            text: i18n("Night Color")
            icon: "redshift-status-on"
            enabled: compositorAdaptor.active
            settingsCommand: "plasma-settings -m kcm_nightcolor"

            CC.CompositorAdaptor {
                id: compositorAdaptor
            }
            function toggle() {
                if (compositorAdaptor.active) {
                    compositorAdaptor.activeStaged = false;
                } else {
                    compositorAdaptor.activeStaged = true;
                    compositorAdaptor.modeStaged = 3; // always on
                }
                compositorAdaptor.sendConfigurationAll();
                enabled = compositorAdaptor.active;
            }
        }
    ]

    PlasmaNM.Handler {
        id: nmHandler
    }

    PlasmaNM.EnabledConnections {
        id: enabledConnections
    }
}
