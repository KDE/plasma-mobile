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
import org.kde.plasma.components 3.0 as PlasmaComponents

import org.kde.plasma.private.mobileshell as MobileShell
import org.kde.plasma.private.mobileshell.state as MobileShellState
import org.kde.plasma.private.mobileshell.windowplugin as WindowPlugin

import org.kde.taskmanager as TaskManager
import org.kde.notificationmanager as NotificationManager

ContainmentItem {
    id: root
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
    Plasmoid.status: PlasmaCore.Types.PassiveStatus // ensure that the panel never takes focus away from the running app

    onWidthChanged: maximizeTimer.restart()

    // filled in by the shell (Panel.qml) with the plasma-workspace PanelView
    property var panel: null
    onPanelChanged: {
        if (panel) {
            panel.floating = false;
        }
    }

    // Ensure that panel is always the full width of the screen
    Timer {
        id: maximizeTimer
        running: false
        interval: 100
        onTriggered: root.panel.maximize()
    }

    // only opaque if there are no maximized windows on this screen
    readonly property bool showingStartupFeedback: MobileShellState.ShellDBusObject.startupFeedbackModel.activeWindowIsStartupFeedback && windowMaximizedTracker.windowCount === 1
    readonly property bool showingApp: windowMaximizedTracker.showingWindow && !showingStartupFeedback
    readonly property color backgroundColor: topPanel.colorScopeColor

    WindowPlugin.WindowMaximizedTracker {
        id: windowMaximizedTracker
        screenGeometry: Plasmoid.containment.screenGeometry
    }

    // enforce thickness
    Binding {
        target: panel // assumed to be plasma-workspace "PanelView" component
        property: "thickness"
        value: MobileShell.Constants.topPanelHeight
    }

//BEGIN API implementation

    Connections {
        target: MobileShellState.ShellDBusClient

        function onOpenActionDrawerRequested() {
            drawer.actionDrawer.open();
        }

        function onCloseActionDrawerRequested() {
            drawer.actionDrawer.close();
        }

        function onDoNotDisturbChanged() {
            if (drawer.actionDrawer.notificationsWidget.doNotDisturbModeEnabled !== MobileShellState.ShellDBusClient.doNotDisturb) {
                drawer.actionDrawer.notificationsWidget.toggleDoNotDisturbMode();
            }
        }
    }

    Binding {
        target: MobileShellState.ShellDBusClient
        property: "isActionDrawerOpen"
        value: drawer.visible
    }

//END API implementation

    Component.onCompleted: {
        // register dbus
        MobileShellState.ShellDBusObject.registerObject();

        // HACK: we need to initialize the DBus server somewhere, it might as well be here...
        // initialize the volume osd, and volume keys
        MobileShell.VolumeOSDProviderLoader.load();
        // initialize notification popups
        MobileShell.NotificationPopupProviderLoader.load();
    }

    MobileShell.StartupFeedbackPanelFill {
        id: startupFeedbackColorAnimation
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right

        fullHeight: root.height
        screen: Plasmoid.screen
        maximizedTracker: windowMaximizedTracker
    }

    // top panel component
    MobileShell.StatusBar {
        id: topPanel
        anchors.fill: parent

        Kirigami.Theme.colorSet: root.showingApp ? Kirigami.Theme.Header : Kirigami.Theme.Complementary
        Kirigami.Theme.inherit: false

        showDropShadow: !root.showingApp
        backgroundColor: !root.showingApp ? "transparent" : root.backgroundColor
    }

    // swiping area for swipe-down drawer
    MobileShell.ActionDrawerOpenSurface {
        id: swipeArea
        actionDrawer: drawer.actionDrawer
        anchors.fill: parent
    }

    // swipe-down drawer component
    MobileShell.ActionDrawerWindow {
        id: drawer

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
    }
}
