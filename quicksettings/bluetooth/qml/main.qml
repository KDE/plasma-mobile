// SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick 2.15

import org.kde.bluezqt 1.0 as BluezQt
import org.kde.plasma.private.mobileshell as MobileShell
import org.kde.plasma.private.mobileshell.quicksettingsplugin as QS

QS.QuickSetting {
    property QtObject btManager: BluezQt.Manager
    property var connectedDevices: []

    id: root

    text: i18n("Bluetooth")
    icon: MobileShell.BluetoothInfo.icon
    settingsCommand: "plasma-open-settings kcm_bluetooth"

    function toggle() {
        if (!btManager) {
            return;
        }

        const enable = !btManager.bluetoothOperational;
        btManager.bluetoothBlocked = !enable;

        for (var i = 0; i < btManager.adapters.length; ++i) {
            btManager.adapters[i].powered = enable;
        }
    }
    enabled: btManager && btManager.bluetoothOperational

    Connections {
        target: btManager

        function onDeviceAdded() {
            updateConnectedDevices();
        }
        function onDeviceRemoved() {
            updateConnectedDevices();
        }
        function onDeviceChanged() {
            updateConnectedDevices();
        }
        function onBluetoothBlockedChanged() {
            updateConnectedDevices();
        }
        function onBluetoothOperationalChanged() {
            updateConnectedDevices();
        }
    }

    function updateConnectedDevices() {
        if (!btManager) {
            return;
        }

        let _connectedDevices = [];
        for (let i = 0; i < btManager.devices.length; ++i) {
            const device = btManager.devices[i];
            if (device.connected) {
                _connectedDevices.push(device);
            }
        }

        if (connectedDevices != _connectedDevices) {
            connectedDevices = _connectedDevices;

            if (connectedDevices.length === 0) {
                root.status = ""
            } else if (connectedDevices.length === 1) {
                root.status = formatDevice(0);
            } else {
                let text = "";
                for (let i = 0; i < connectedDevices.length; i++) {
                    const device = connectedDevices[i];
                    const battery = device.battery;
                    text += formatDevice(i) + " \u2022 ";
                }

                // trims until the last dot
                text = text.substring(0, text.length - 2);

                root.status = text;
            }
        }
    }

    function formatDevice(deviceIndex) {
        const device = connectedDevices[deviceIndex];
        const battery = device.battery;
        const name = device.name;

        return battery
            ? "%1 · %2".arg(name).arg(battery.percentage)
            : name;
    }
}
