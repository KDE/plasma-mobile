/*
    SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
    SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2013-2017 Jan Grulich <jgrulich@redhat.com>

    SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL
*/

import QtQuick 2.2
import QtQuick.Layouts 1.4
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.bluezqt 1.0 as BluezQt

pragma Singleton

QtObject {
    property bool isVisible: BluezQt.Manager.bluetoothOperational
    property string icon: deviceConnected ? "preferences-system-bluetooth-activated" : "preferences-system-bluetooth"
    
    property bool deviceConnected : false
    
    function updateStatus() {
        var connectedDevices = [];

        for (var i = 0; i < BluezQt.Manager.devices.length; ++i) {
            var device = BluezQt.Manager.devices[i];
            if (device.connected) {
                connectedDevices.push(device);
            }
        }
        deviceConnected = connectedDevices.length > 0;
    }
    
    Component.onCompleted: {
        BluezQt.Manager.deviceAdded.connect(updateStatus);
        BluezQt.Manager.deviceRemoved.connect(updateStatus);
        BluezQt.Manager.deviceChanged.connect(updateStatus);
        BluezQt.Manager.bluetoothBlockedChanged.connect(updateStatus);
        BluezQt.Manager.bluetoothOperationalChanged.connect(updateStatus);

        updateStatus();
    }
}

