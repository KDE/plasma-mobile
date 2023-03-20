/*
 *  SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 *  SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Window 2.15
import QtQml.Models 2.12

import org.kde.kirigami 2.12 as Kirigami

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents

import org.kde.plasma.private.mobileshell as MobileShell
import org.kde.plasma.private.mobileshell.state as MobileShellState
import org.kde.plasma.private.mobileshell.windowplugin as WindowPlugin

import org.kde.taskmanager 0.1 as TaskManager
import org.kde.notificationmanager 1.0 as NotificationManager

Item {
    id: root

    // only opaque if there are no maximized windows on this screen
    readonly property bool showingApp: WindowPlugin.WindowMaximizedTracker.showingWindow
    readonly property color backgroundColor: topPanel.colorScopeColor

    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
    
    width: 480
    height: PlasmaCore.Units.gridUnit

    // enforce thickness
    Binding {
        target: plasmoid.Window.window // assumed to be plasma-workspace "PanelView" component
        property: "thickness"
        value: PlasmaCore.Units.gridUnit + PlasmaCore.Units.smallSpacing
    }
    
//BEGIN API implementation

    Connections {
        target: MobileShellState.ShellDBusClient

        function onOpenActionDrawerRequested() {
            drawer.actionDrawer.open();
        }

        function onCloseActionDrawerRequested() {
            console.log('action drawer close');
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
        // we want to bind global volume shortcuts here
        MobileShellState.AudioProvider.bindShortcuts = true;
    }
    
    // top panel component
    MobileShell.StatusBar {
        id: topPanel
        anchors.fill: parent
        
        showDropShadow: !root.showingApp
        colorGroup: root.showingApp ? PlasmaCore.Theme.HeaderColorGroup : PlasmaCore.Theme.ComplementaryColorGroup
        backgroundColor: !root.showingApp ? "transparent" : root.backgroundColor
    }
    
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
