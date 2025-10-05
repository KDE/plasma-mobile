// SPDX-FileCopyrightText: 2021-2023 Devin Lin <devin@kde.org>
// SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Window
import QtQml.Models

import org.kde.kirigami as Kirigami

import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore

import org.kde.plasma.private.mobileshell as MobileShell
import org.kde.plasma.private.mobileshell.shellsettingsplugin as ShellSettings
import org.kde.plasma.private.mobileshell.state as MobileShellState
import org.kde.plasma.private.mobileshell.windowplugin as WindowPlugin

import org.kde.taskmanager as TaskManager
import org.kde.notificationmanager as NotificationManager
import org.kde.layershell 1.0 as LayerShell

ContainmentItem {
    id: root

    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
    Plasmoid.status: PlasmaCore.Types.PassiveStatus // Ensure that the panel never takes focus away from the running app

    // Filled in by the shell (Panel.qml) with the plasma-workspace PanelView
    property var panel: null
    onPanelChanged: setWindowProperties()

    // Whether the startup feedback is showing
    readonly property bool showingStartupFeedback: MobileShellState.ShellDBusObject.startupFeedbackModel.activeWindowIsStartupFeedback

    // Whether an app is maximized and showing (does not include startup feedback)
    readonly property bool showingApp: windowMaximizedTracker.showingWindow && !showingStartupFeedback

    // Whether the currently showing app is in "fullscreen"
    readonly property bool fullscreen: {
        if (windowMaximizedTracker.isCurrentWindowFullscreen) {
            return true;
        }

        // The "autoHidePanelsEnabled" settings option treats every app as a fullscreen window
        return (ShellSettings.Settings.autoHidePanelsEnabled && showingApp);
    }
    onFullscreenChanged: {
        MobileShellState.ShellDBusClient.panelState = fullscreen ? "hidden" : "default";
    }

    property WindowPlugin.WindowMaximizedTracker windowMaximizedTracker: WindowPlugin.WindowMaximizedTracker {
        id: windowMaximizedTracker
        screenGeometry: Plasmoid.containment.screenGeometry

        onShowingWindowChanged: {
            // Hide panel when we open the task switcher and an app is "fullscreen"
            if (windowMaximizedTracker.showingWindow
                && MobileShellState.ShellDBusClient.isTaskSwitcherVisible
                && (ShellSettings.Settings.autoHidePanelsEnabled || fullscreen)) {
                MobileShellState.ShellDBusClient.panelState = "hidden";
            }
        }
    }

    readonly property real panelHeight: MobileShell.Constants.topPanelHeight
    onPanelHeightChanged: setWindowProperties()

    function setWindowProperties() {
        if (root.panel) {
            root.panel.floating = false;
            root.panel.maximize(); // maximize first, then we can apply offsets (otherwise they are overridden)

            // HACK: set thickness twice, sometimes it doesn't set the first time??
            root.panel.thickness = root.panelHeight;
            root.panel.thickness = root.panelHeight;

            root.panel.visibilityMode = ShellSettings.Settings.autoHidePanelsEnabled ? 3 : 0;
            MobileShell.ShellUtil.setWindowLayer(root.panel, LayerShell.Window.LayerOverlay)
            root.updateTouchArea();
        }
    }

    // Update the touch area when hidden to minimize the space the panel takes for touch input
    function updateTouchArea() {
        const hiddenTouchAreaThickness = Kirigami.Units.gridUnit;

        if (MobileShellState.ShellDBusClient.panelState == "hidden") {
            MobileShell.ShellUtil.setInputRegion(root.panel, Qt.rect(0, 0, root.panel.width, hiddenTouchAreaThickness));
        } else {
            MobileShell.ShellUtil.setInputRegion(root.panel, Qt.rect(0, 0, 0, 0));
        }
    }

    Connections {
        target: root.panel

        function onThicknessChanged() {
            if (root.panel.thickness !== root.panelHeight) {
                root.panel.thickness = root.panelHeight;
            }
        }
    }

    // Overlay the panel over the lockscreen when brought up
    LockscreenOverlay {
        window: root.Window.window
    }

    Connections {
        target: ShellSettings.Settings

        function onAutoHidePanelsEnabledChanged() {
            root.setWindowProperties();
        }
    }

    Component.onCompleted: {
        root.setWindowProperties();
    }

    // Visual panel component
    StatusPanel {
        id: statusPanel
        anchors.fill: parent
        containmentItem: root
    }
}
