// SPDX-FileCopyrightText: 2025 Florian RICHER <florian.richer@protonmail.com>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick

import org.kde.plasma.private.mobileshell.dpmsplugin as DPMS
import org.kde.plasma.private.mobileshell.state as MobileShellState

Item {
    id: root

    property real doubleClickInterval: 400
    property int tapCount: 0
    property bool isSwiping: false

    signal doubleTapped()

    onDoubleTapped: {
        MobileShellState.LockscreenDBusClient.lockScreen()
        dpms.turnDpmsOff()
    }

    DPMS.DPMSUtil {
        id: dpms
    }

    // Workaround for double tap detection without capture events for HomeScreen
    Timer {
        id: doubleClickTimer
        interval: root.doubleClickInterval
        onTriggered: {
            root.tapCount = 0
        }
    }

    MouseArea {
        anchors.fill: parent
        propagateComposedEvents: true

        onReleased: {
            mouse.accepted = false

            if (root.isSwiping) {
                // Reset the isSwiping flag to re-enable double tap detection
                root.isSwiping = false
                return
            }

            root.tapCount++;
            if (root.tapCount === 2) {
                root.doubleTapped()
            }

            doubleClickTimer.restart()
        }

        // If is swiping, we don't want to trigger the double tap
        onPositionChanged: {
            mouse.accepted = false
            doubleClickTimer.stop()
            root.tapCount = 0
            root.isSwiping = true
        }
    }
}

