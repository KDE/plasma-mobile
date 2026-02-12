// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Window

import org.kde.plasma.private.mobileshell as MobileShell
import org.kde.plasma.private.mobileshell.state as MobileShellState
import org.kde.plasma.private.mobileshell.raiselockscreenplugin as RaiseLockscreenPlugin

import org.kde.layershell 1.0 as LayerShell

// Raise panel window over the lockscreen when it is shown
QtObject {
    id: root
    required property var window

    onWindowChanged: {
        // Window.window may start out null, we need to wait for it to exist
        if (root.window && !raiseLockscreen.initialized) {
            initializeLockscreenOverlay();
        }
    }

    function raiseOverlay() {
        if (MobileShellState.LockscreenDBusClient.lockscreenActive) {
            console.log('Raising top panel over the lockscreen');
            raiseLockscreen.raiseOverlay();
        }
    }

     function initializeLockscreenOverlay() {
        if (!root.window) {
            return;
        }

        raiseLockscreen.initializeOverlay(root.window);

        // Raise panel if lockscreen is already active
        raiseOverlay();
    }

    // Raise panel over the lockscreen when it is enabled
    readonly property var raiseLockscreen: RaiseLockscreenPlugin.RaiseLockscreen {
        id: raiseLockscreen
        Component.onCompleted: root.initializeLockscreenOverlay()
    }

    readonly property Connections lockscreenConnections: Connections {
        target: MobileShellState.LockscreenDBusClient

        function onLockscreenLocked() {
            root.raiseOverlay();
        }
    }
}