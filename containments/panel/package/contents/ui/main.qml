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
import org.kde.layershell 1.0 as LayerShell

ContainmentItem {
    id: root
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
    Plasmoid.status: PlasmaCore.Types.PassiveStatus // ensure that the panel never takes focus away from the running app

    // filled in by the shell (Panel.qml) with the plasma-workspace PanelView
    property var panel: null
    onPanelChanged: setWindowProperties()

    MobileShell.HapticsEffect {
        id: haptics
    }

    readonly property real statusPanelHeight: MobileShell.Constants.topPanelHeight
    readonly property real intendedWindowThickness: statusPanelHeight

    // use a timer so we don't have to maximize for every single pixel
    // - improves performance if the shell is run in a window, and can be resized
    Timer {
        id: maximizeTimer
        running: false
        interval: 100
        onTriggered:  root.panel.maximize()
    }

    function setWindowProperties() {
        if (root.panel) {
            root.panel.floating = false;
            root.panel.maximize(); // maximize first, then we can apply offsets (otherwise they are overridden)
            root.panel.thickness = statusPanelHeight;
            MobileShell.ShellUtil.setWindowLayer(root.panel, LayerShell.Window.LayerOverlay)
            root.updateTouchArea();
        }
    }

    // update the touch area when hidden to minimize the space the panel takes for touch input
    function updateTouchArea() {
        const hiddenTouchAreaThickness = Kirigami.Units.gridUnit;

        if (statusPanel.state == "hidden") {
            MobileShell.ShellUtil.setInputRegion(root.panel, Qt.rect(0, 0, root.panel.width, hiddenTouchAreaThickness));
        } else {
            MobileShell.ShellUtil.setInputRegion(root.panel, Qt.rect(0, 0, 0, 0));
        }
    }


    Binding {
        target: MobileShellState.ShellDBusClient
        property: "isActionDrawerOpen"
        value: drawer.visible
    }


    // only opaque if there are no maximized windows on this screen
    readonly property bool showingStartupFeedback: MobileShellState.ShellDBusObject.startupFeedbackModel.activeWindowIsStartupFeedback && windowMaximizedTracker.windowCount === 1
    readonly property bool showingApp: windowMaximizedTracker.showingWindow && !showingStartupFeedback
    readonly property color backgroundColor: topPanel.colorScopeColor
    readonly property alias isCurrentWindowFullscreen: windowMaximizedTracker.isCurrentWindowFullscreen
    onIsCurrentWindowFullscreenChanged: {
        MobileShellState.ShellDBusClient.panelState = isCurrentWindowFullscreen ? "hidden" : "default";
    }

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
        value: drawer.intendedToBeVisible
    }

//END API implementation

    Component.onCompleted: {
        root.setWindowProperties();

        // register dbus
        MobileShellState.ShellDBusObject.registerObject();

        // HACK: we need to initialize the DBus server somewhere, it might as well be here...
        // initialize the volume osd, and volume keys
        // initialize notification popups
        MobileShell.PopupProviderLoader.load();
    }

    MobileShell.StartupFeedbackPanelFill {
        id: startupFeedbackColorAnimation
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right

        fullHeight: root.height
        screen: Plasmoid.screen
        maximizedTracker: windowMaximizedTracker

        visible: !root.isCurrentWindowFullscreen
    }

    Rectangle {
        id: statusPanel
        anchors.fill: parent
        Kirigami.Theme.colorSet: root.showingApp ? Kirigami.Theme.Header : Kirigami.Theme.Complementary
        Kirigami.Theme.inherit: false

        color: statusPanel.state == "default" && root.showingApp ? Kirigami.Theme.backgroundColor : "transparent"

        property real offset: 0

        // top panel component
        MobileShell.StatusBar {
            id: topPanel
            anchors.fill: parent

            showDropShadow: !root.showingApp
            backgroundColor: statusPanel.state != "default" ? Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.95) : "transparent"

            transform: [
                Translate {
                    y: statusPanel.offset
                }
            ]
        }

        state: MobileShellState.ShellDBusClient.panelState
        onStateChanged: {
            if (statusPanel.state != "hidden") {
                root.setWindowProperties();
                hiddenTimer.restart();
            }
        }

        Timer {
            id: hiddenTimer
            running: false
            interval: 3000
            onTriggered: {
                if (statusPanel.state == "visible") {
                    MobileShellState.ShellDBusClient.panelState = "hidden";
                }
            }
        }

        states: [
            State {
                name: "default"
                PropertyChanges {
                    target: statusPanel; offset: 0
                }
            },
            State {
                name: "visible"
                PropertyChanges {
                    target: statusPanel; offset: 0
                }
            },
            State {
                name: "hidden"
                PropertyChanges {
                    target: statusPanel; offset: -root.statusPanelHeight
                }
            }
        ]

        transitions: Transition {
            SequentialAnimation {
                ParallelAnimation {
                    PropertyAnimation {
                        properties: "offset"; easing.type: statusPanel.state == "hidden" ? Easing.InExpo : Easing.OutExpo; duration: Kirigami.Units.longDuration
                    }
                }
                ScriptAction {
                    script: {
                        root.setWindowProperties();
                    }
                }
            }
        }
    }

    // swiping area for swipe-down drawer
    MobileShell.ActionDrawerOpenSurface {
        id: swipeArea
        actionDrawer: drawer.actionDrawer
        anchors.fill: parent

        readonly property alias drawerVisible: drawer.visible
        readonly property alias offset: drawer.actionDrawer.offset
        property bool surfacePressed: false
        onOffsetChanged: surfacePressed = false

        // allow tapping to bring back up the status bar when it is hidden
        onPressedChanged: {
            if (!pressed && surfacePressed && root.isCurrentWindowFullscreen) {
                haptics.buttonVibrate();
                MobileShellState.ShellDBusClient.panelState = "visible";
            } else {
                surfacePressed = true;
            }
        }

        // if in a fullscreen app, the panels are visible, and the action drawer is opened
        // set the panels to a hidden state
        onDrawerVisibleChanged: {
            if (statusPanel.state == "visible") {
                MobileShellState.ShellDBusClient.panelState = "hidden";
            }
        }
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
