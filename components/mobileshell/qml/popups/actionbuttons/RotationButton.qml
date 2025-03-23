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

    // Update button position and timeout when device rotation changes.
    onDeviceRotationChanged: {
        if (!showRotationButton || ShellSettings.Settings.navigationPanelEnabled) return;
        // Position at the bottom left edge of actual device, regardless of current rotation.
        root.screenCorner = (deviceRotation - currentRotation) % 4;
        // match angle to physical device rotation.
        root.angle = ((deviceRotation - currentRotation) % 4) * 90;
        root.active = true;
    }

    // Rotate to suggested rotation if button is pressed.
    onTriggered: {
        RotationPlugin.RotationUtil.rotateToSuggestedRotation();
    }

    // When the button is active, hide it after a certain amount of time has passed.
    // This is to prevent the button form bothering the user when they do not wish to rotate.
    onActiveChanged: if (active) timeout.restart();

    Timer {
        id: timeout
        interval: 10000
        repeat: false
        onTriggered: active = false;
    }
}
