// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Window

import org.kde.plasma.private.mobileshell.state as MobileShellState
import org.kde.plasma.private.mobileshell.raiselockscreenplugin as RaiseLockscreenPlugin

// Raise panel over the lockscreen when it is shown
QtObject {
    id: root
    required property var window

    onWindowChanged: {
        // Window.window may start out null, we need to wait for it to exist
        console.log('WINDOWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW ' + root.window);
        if (root.window && !raiseLockscreen.initialized) {
            raiseLockscreen.initializeOverlay(root.window);
        }
    }

    // Raise panel over the lockscreen when it is enabled
    readonly property var raiseLockscreen: RaiseLockscreenPlugin.RaiseLockscreen {
        id: raiseLockscreen

        function initializeLockscreenOverlay() {
            if (!root.window) {
                return;
            }

            raiseLockscreen.initializeOverlay(root.window);

            // Raise panel if lockscreen is already active
            if (MobileShellState.LockscreenDBusClient.lockscreenActive) {
                raiseLockscreen.raiseOverlay();
            }
        }

        Component.onCompleted: initializeLockscreenOverlay()
    }

    readonly property Connections lockscreenConnections: Connections {
        target: MobileShellState.LockscreenDBusClient

        function onLockscreenLocked() {
            console.log('Raising top panel over the lockscreen');
            raiseLockscreen.raiseOverlay();
        }
    }
}