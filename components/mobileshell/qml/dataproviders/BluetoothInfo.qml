/*
    SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
    SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2013-2017 Jan Grulich <jgrulich@redhat.com>

    SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL
*/

pragma Singleton

import QtQuick 2.2
import QtQuick.Layouts 1.4
import org.kde.bluezqt 1.0 as BluezQt

QtObject {
    id: root
    readonly property bool isVisible: BluezQt.Manager.bluetoothOperational
    readonly property string icon: deviceConnected ? "network-bluetooth-activated" : "network-bluetooth"

    property bool deviceConnected: false

    function updateStatus() {
        let connectedDevices = [];

        for (var i = 0; i < BluezQt.Manager.devices.length; ++i) {
            var device = BluezQt.Manager.devices[i];
            if (device.connected) {
                connectedDevices.push(device);
            }
        }

        root.deviceConnected = connectedDevices.length > 0;
    }

    property var connections: Connections {
        target: BluezQt.Manager

        function onDeviceAdded() {
            root.updateStatus();
        }
        function onDeviceRemoved() {
            root.updateStatus();
        }
        function onDeviceChanged() {
            root.updateStatus();
        }
        function onBluetoothBlockedChanged() {
            root.updateStatus();
        }
        function onBluetoothOperationalChanged() {
            root.updateStatus();
        }
    }

    Component.onCompleted: {
        updateStatus();
    }
}

