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
    property alias model: settingsModel
    property bool screenshotRequested: false
    
    signal panelClosed()
    
    onPanelClosed: {
        if (screenshotRequested) {
            plasmoid.nativeInterface.takeScreenshot();
            screenshotRequested = false;
        }
    }
    
    ListModel {
        id: settingsModel
    }
    
    PlasmaNM.Handler {
        id: nmHandler
    }

    PlasmaNM.EnabledConnections {
        id: enabledConnections
    }
    
    // night color
    CC.CompositorAdaptor {
        id: compositorAdaptor
    }
    
    Connections {
        target: BluezQt.Manager
        function onBluetoothOperationalChanged() {
            settingsModel.get(2).enabled = BluezQt.Manager.bluetoothOperational
        }
    }

    function toggleAirplane() {
        print("toggle airplane mode")
    }

    function toggleTorch() {
        plasmoid.nativeInterface.toggleTorch()
        settingsModel.get(6).enabled = plasmoid.nativeInterface.torchEnabled
    }

    function toggleWifi() {
        nmHandler.enableWireless(!enabledConnections.wirelessEnabled)
        settingsModel.get(1).enabled = !enabledConnections.wirelessEnabled
    }

    function toggleWwan() {
        nmHandler.enableWwan(!enabledConnections.wwanEnabled)
        settingsModel.get(3).enabled = !enabledConnections.wwanEnabled
    }

    function toggleRotation() {
        const enable = !plasmoid.nativeInterface.autoRotateEnabled
        plasmoid.nativeInterface.autoRotateEnabled = enable
        settingsModel.get(9).enabled = enable
    }

    function toggleBluetooth() {
        var enable = !BluezQt.Manager.bluetoothOperational;
        BluezQt.Manager.bluetoothBlocked = !enable;

        for (var i = 0; i < BluezQt.Manager.adapters.length; ++i) {
            var adapter = BluezQt.Manager.adapters[i];
            adapter.powered = enable;
        }
    }
    
    function toggleNightColor() {
        if (compositorAdaptor.active) {
            compositorAdaptor.activeStaged = false;
        } else {
            compositorAdaptor.activeStaged = true;
            compositorAdaptor.modeStaged = 3; // always on
        }
        compositorAdaptor.sendConfigurationAll();
        settingsModel.get(10).enabled = compositorAdaptor.active;
    }
    
    // components needed for quick settings
    function requestScreenshot() {
        screenshotRequested = true;
        root.closeRequested();
    }
    
    function openVolumeOsd() {
        volumeProvider.showVolumeOverlay();
    }
    
    // initialize quick settings
    Component.onCompleted: {
        //NOTE: add all in javascript as the static decl of listelements can't have scripts
        settingsModel.append({
            "text": i18n("Settings"),
            "icon": "configure",
            "enabled": false,
            "settingsCommand": "plasma-settings",
            "toggleFunction": ""
        });
        settingsModel.append({
            "text": i18n("Wifi"),
            "icon": "network-wireless-signal",
            "settingsCommand": "plasma-settings -m kcm_mobile_wifi",
            "toggleFunction": "toggleWifi",
            "enabled": enabledConnections.wirelessEnabled
        });
        settingsModel.append({
            "text": i18n("Bluetooth"),
            "icon": "network-bluetooth",
            "settingsCommand": "plasma-settings -m kcm_bluetooth",
            "toggleFunction": "toggleBluetooth",
            "delegate": "",
            "enabled": BluezQt.Manager.bluetoothOperational
        });
        settingsModel.append({
            "text": i18n("Mobile Data"),
            "icon": "network-modem",
            "settingsCommand": "plasma-settings -m kcm_mobile_broadband",
            "toggleFunction": "toggleWwan",
            "enabled": enabledConnections.wwanEnabled
        });
        settingsModel.append({
            "text": i18n("Battery"),
            "icon": "battery-full",
            "enabled": false,
            "settingsCommand": "plasma-settings -m kcm_mobile_power",
            "toggleFunction": ""
        });
        settingsModel.append({
            "text": i18n("Sound"),
            "icon": "audio-speakers-symbolic",
            "enabled": false,
            "settingsCommand": "plasma-settings -m kcm_pulseaudio",
            "toggleFunction": "openVolumeOsd"
        });
        settingsModel.append({
            "text": i18n("Flashlight"),
            "icon": "flashlight-on",
            "enabled": plasmoid.nativeInterface.torchEnabled,
            "settingsCommand": "",
            "toggleFunction": "toggleTorch"
        });
        settingsModel.append({
            "text": i18n("Location"),
            "icon": "gps",
            "enabled": false,
            "settingsCommand": ""
        });
        settingsModel.append({
            "text": i18n("Screenshot"),
            "icon": "spectacle",
            "enabled": false,
            "settingsCommand": "",
            "toggleFunction": "requestScreenshot"
        });
        settingsModel.append({
            "text": i18n("Auto-rotate"),
            "icon": "rotation-allowed",
            "enabled": plasmoid.nativeInterface.autoRotateEnabled,
            "settingsCommand": "",
            "toggleFunction": "toggleRotation"
        });
        settingsModel.append({
            "text": i18n("Night Color"),
            "icon": "redshift-status-on",
            "enabled": compositorAdaptor.active,
            "settingsCommand": "", // change once night color kcm is added
            "toggleFunction": "toggleNightColor"
        });
    }
}
