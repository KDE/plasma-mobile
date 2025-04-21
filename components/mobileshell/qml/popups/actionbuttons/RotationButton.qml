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
        if (ShellSettings.Settings.navigationPanelEnabled) return;
        // reset button if visible
        if (root.visible) {
            root.active = false;
            timeout.stop();
        }
        if (!RotationPlugin.RotationUtil.showRotationButton) return;
        // Position at the bottom left edge of actual device, regardless of current rotation.
        root.screenCorner = (currentRotation + 1) % 4;
        // match angle to physical device rotation.
        root.angle = ((4 + currentRotation - deviceRotation) % 4) * 90;
        root.active = true;
    }

    // Rotate to suggested rotation if button is pressed.
    onTriggered: {
        root.visible = false;
        root.active = false;
        timeout.stop();
        rotate.restart();
    }

    // rotate on timeout to give time to hide the button before rotation happens
    Timer {
        id: rotate
        interval: 0
        repeat: false
        onTriggered: RotationPlugin.RotationUtil.rotateToSuggestedRotation();
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
