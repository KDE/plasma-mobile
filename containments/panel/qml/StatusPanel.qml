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

Item {
    id: root

    // The base containment item
    property ContainmentItem containmentItem

//BEGIN API implementation

    Connections {
        target: MobileShellState.ShellDBusClient

        function onOpenActionDrawerRequested() {
            drawer.actionDrawer.open();
        }

        function onCloseActionDrawerRequested() {
            drawer.actionDrawer.close();
        }
    }

    Binding {
        target: MobileShellState.ShellDBusClient
        property: "isActionDrawerOpen"
        value: drawer.visible
    }

//END API implementation

    // Startup feedback fill animation
    MobileShell.StartupFeedbackPanelFill {
        id: startupFeedbackColorAnimation
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right

        fullHeight: containmentItem.height
        screen: Plasmoid.screen
        maximizedTracker: containmentItem.windowMaximizedTracker

        visible: !MobileShellState.LockscreenDBusClient.lockscreenActive && !containmentItem.fullscreen
    }

    // Status bar component
    StatusBarWrapper {
        id: statusBarWrapper
        anchors.fill: parent

        statusPanelHeight: MobileShell.Constants.topPanelHeight
        transparentBackground: {
            // If we are over the lockscreen, always have a transparent background.
            if (MobileShellState.LockscreenDBusClient.lockscreenActive) {
                return true;
            }

            return !containmentItem.showingApp && !containmentItem.fullscreen;
        }
        forcedComplementary: {
            if (MobileShellState.LockscreenDBusClient.lockscreenActive) {
                return true;
            }

            // Force complementary colors (white) unless the startup feedback is showing
            return transparentBackground && !startupFeedbackColorAnimation.isShowing
        }

        state: {
            // If we are on the lockscreen, always show the status panel.
            if (MobileShellState.LockscreenDBusClient.lockscreenActive) {
                return "default";
            }

            return MobileShellState.ShellDBusClient.panelState;
        }
        onStateChanged: {
            if (state != "hidden") {
                containmentItem.setWindowProperties();
                hiddenTimer.restart();
            }
        }

        onUpdatePanelPropertiesRequested: containmentItem.setWindowProperties()

        // Hide status bar panel if it is visible for 3 seconds (in forced "visible" mode).
        Timer {
            id: hiddenTimer
            running: false
            interval: 3000
            onTriggered: {
                if (statusBarWrapper.state == "visible") {
                    MobileShellState.ShellDBusClient.panelState = "hidden";
                }
            }
        }
    }

    // Swiping area for swipe-down drawer
    MobileShell.ActionDrawerOpenSurface {
        id: swipeArea
        actionDrawer: drawer.actionDrawer
        anchors.fill: parent

        readonly property alias drawerVisible: drawer.visible
        readonly property alias offset: drawer.actionDrawer.offset

        // if in a fullscreen app, the panels are visible, and the action drawer is opened
        // set the panels to a hidden state
        onDrawerVisibleChanged: {
            if (statusBarWrapper.state == "visible") {
                MobileShellState.ShellDBusClient.panelState = "hidden";
            }
        }
    }

    // Swipe-down drawer component
    MobileShell.ActionDrawerWindow {
        id: drawer

        onVisibleChanged: {
            if (visible && MobileShellState.LockscreenDBusClient.lockscreenActive) {
                // This works as long the wayland surface is the same (no window.close(), just window.visible = false)
                lockScreenOverlay.raiseOverlay();
            }
        }

        LockscreenOverlay {
            id: lockScreenOverlay
            window: drawer
        }

        actionDrawer.restrictedPermissions: MobileShellState.LockscreenDBusClient.lockscreenActive

        actionDrawer.notificationSettings: NotificationManager.Settings {}
        actionDrawer.notificationModel: NotificationManager.Notifications {
            showExpired: true
            showDismissed: true
            showJobs: drawer.actionDrawer.notificationSettings.jobsInNotifications
            sortMode: NotificationManager.Notifications.SortByTypeAndUrgency
            groupMode: NotificationManager.Notifications.GroupApplicationsFlat
            groupLimit: 2
            expandUnread: true
            blacklistedDesktopEntries: drawer.actionDrawer.notificationSettings.historyBlacklistedApplications
            blacklistedNotifyRcNames: drawer.actionDrawer.notificationSettings.historyBlacklistedServices
            urgencies: {
                var urgencies = NotificationManager.Notifications.CriticalUrgency
                            | NotificationManager.Notifications.NormalUrgency;
                if (drawer.actionDrawer.notificationSettings.lowPriorityHistory) {
                    urgencies |= NotificationManager.Notifications.LowUrgency;
                }
                return urgencies;
            }
        }

        Connections {
            target: drawer.actionDrawer

            function onPermissionsRequested() {
                MobileShellState.ShellDBusClient.openLockScreenKeypad();
            }
        }

        Connections {
            target: MobileShellState.LockscreenDBusClient

            function onLockscreenUnlocked() {
                // Run pending actions after the lockscreen gets unlocked
                drawer.actionDrawer.runPendingNotificationAction();
            }
        }
    }
}
