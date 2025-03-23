/*
 *  SPDX-FileCopyrightText: 2025 Micah Stanley <stanleymicah@proton.me>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick
import QtQuick.Layouts

import org.kde.plasma.private.mobileshell.rotationplugin as RotationPlugin
import org.kde.plasma.private.mobileshell.shellsettingsplugin as ShellSettings

ActionButton {
    id: root

    readonly property int deviceRotation: RotationPlugin.RotationUtil.deviceRotation
    readonly property int currentRotation: RotationPlugin.RotationUtil.currentRotation

    iconSource: "rotation-allowed-symbolic"
    angle: ((deviceRotation - currentRotation) % 4) * 90
    screenEdge: (deviceRotation - currentRotation) % 4

    onActiveChanged: {
        if (!active) return;
        timeout.restart();
    }

    onDeviceRotationChanged: {
        if (!showRotationButton || ShellSettings.Settings.navigationPanelEnabled) return;
        active = true;
        timeout.restart();
    }

    onTriggered: {
        RotationPlugin.RotationUtil.rotateToSuggestedRotation();
    }

    Timer {
        id: timeout
        interval: 10000
        repeat: false
        onTriggered: active = false;
    }
}
