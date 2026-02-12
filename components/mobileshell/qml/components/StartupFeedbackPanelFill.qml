// SPDX-FileCopyrightText: 2024 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL

import QtQuick

import org.kde.plasma.private.mobileshell.state as MobileShellState

// Component to supplement the StartupFeedback window maximization animation for panel backgrounds.

Rectangle {
    id: root

    property real fullHeight
    property int screen
    property var maximizedTracker

    readonly property bool isShowing: height > 0

    // Smooth animation for colored rectangle
    NumberAnimation on height {
        id: heightAnim
        from: 0
        to: root.fullHeight
        duration: 200
        easing.type: Easing.OutExpo
    }

    // Reset when maximized window state changes
    Connections {
        target: maximizedTracker

        function onShowingWindowChanged() {
            root.color = 'transparent';
            root.height = 0;
        }
    }

    // Listen to event from shell dbus
    Connections {
        target: MobileShellState.ShellDBusClient

        function onAppLaunchMaximizePanelAnimationTriggered(screen, color) {
            if (root.screen !== screen) {
                return;
            }

            root.color = color;
            heightAnim.restart();
        }
    }
}
