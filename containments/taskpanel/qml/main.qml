// SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
// SPDX-FileCopyrightText: 2021-2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick 2.4
import QtQuick.Layouts 1.1
import QtQuick.Window 2.15
import QtQuick.Shapes 1.8

import org.kde.kirigami 2.20 as Kirigami

import org.kde.taskmanager 0.1 as TaskManager
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core as PlasmaCore
import org.kde.kquickcontrolsaddons 2.0

import org.kde.plasma.private.mobileshell as MobileShell
import org.kde.plasma.private.mobileshell.shellsettingsplugin as ShellSettings
import org.kde.plasma.private.mobileshell.windowplugin as WindowPlugin
import org.kde.plasma.private.mobileshell.state as MobileShellState
import org.kde.plasma.workspace.keyboardlayout as Keyboards
import org.kde.layershell 1.0 as LayerShell

ContainmentItem {
    id: root
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
    Plasmoid.status: PlasmaCore.Types.PassiveStatus // ensure that the panel never takes focus away from the running app

    // filled in by the shell (Panel.qml) with the plasma-workspace PanelView
    property var panel: null
    onPanelChanged: {
        setWindowProperties()
    }

    MobileShell.HapticsEffect {
        id: haptics
    }

    readonly property bool inLandscape: MobileShell.Constants.navigationPanelOnSide(Screen.width, Screen.height)

    readonly property real navigationPanelHeight: MobileShell.Constants.navigationPanelThickness

    readonly property real intendedWindowThickness: navigationPanelHeight
    readonly property real intendedWindowLength: inLandscape ? Screen.height : Screen.width
    readonly property real intendedWindowOffset: inLandscape ? MobileShell.Constants.topPanelHeight : 0; // offset for top panel
    readonly property int intendedWindowLocation: inLandscape ? PlasmaCore.Types.RightEdge : PlasmaCore.Types.BottomEdge

    onIntendedWindowLengthChanged: maximizeTimer.restart() // ensure it always takes up the full length of the screen
    onIntendedWindowLocationChanged: setPanelLocationTimer.restart()
    onIntendedWindowOffsetChanged: {
        if (root.panel) {
            root.panel.offset = intendedWindowOffset;
        }
    }

    // HACK: the entire shell seems to crash sometimes if this is applied immediately after a display change (ex. screen rotation)
    // see https://invent.kde.org/plasma/plasma-mobile/-/issues/321
    Timer {
        id: setPanelLocationTimer
        running: false
        interval: 100
        onTriggered: {
            root.panel.location = intendedWindowLocation;
        }
    }

    // use a timer so we don't have to maximize for every single pixel
    // - improves performance if the shell is run in a window, and can be resized
    Timer {
        id: maximizeTimer
        running: false
        interval: 100
        onTriggered: {
            // maximize first, then we can apply offsets (otherwise they are overridden)
            root.panel.maximize();
            root.panel.offset = intendedWindowOffset;
        }
    }


    function setWindowProperties() {
        if (root.panel) {
            root.panel.floating = false;
            root.panel.maximize(); // maximize first, then we can apply offsets (otherwise they are overridden)
            root.panel.offset = intendedWindowOffset;
            root.panel.thickness = navigationPanelHeight;
            root.panel.location = intendedWindowLocation;
            root.panel.visibilityMode = ShellSettings.Settings.autoHidePanelsEnabled ? 3 : 0;
            MobileShell.ShellUtil.setWindowLayer(root.panel, LayerShell.Window.LayerOverlay);
            root.updateTouchArea();
        }
    }

    // update the touch area when hidden to minimize the space the panel takes for touch input
    function updateTouchArea() {
        const hiddenTouchAreaThickness = Kirigami.Units.gridUnit;

        if (navigationPanel.state == "hidden") {
            if (inLandscape) {
                MobileShell.ShellUtil.setInputRegion(root.panel, Qt.rect(root.panel.width - hiddenTouchAreaThickness, 0, hiddenTouchAreaThickness, root.panel.height));
            } else {
                MobileShell.ShellUtil.setInputRegion(root.panel, Qt.rect(0, root.panel.height - hiddenTouchAreaThickness, root.panel.width, hiddenTouchAreaThickness));
            }
        } else {
            MobileShell.ShellUtil.setInputRegion(root.panel, Qt.rect(0, 0, 0, 0));
        }
    }

    Connections {
        target: root.panel

        // HACK: There seems to be some component that overrides our initial bindings for the panel,
        //   which is particularly problematic on first start (since the panel is misplaced)
        // - We set an event to override any attempts to override our bindings.
        function onLocationChanged() {
            if (root.panel.location !== root.intendedWindowLocation) {
                root.setWindowProperties();
            }
        }

        function onThicknessChanged() {
            if (root.panel.thickness !== root.intendedWindowThickness) {
                root.setWindowProperties();
            }
        }
    }

    Connections {
        target: ShellSettings.Settings

        function onAutoHidePanelsEnabledChanged() {
            root.setWindowProperties();
        }
    }

    Component.onCompleted: setWindowProperties();

    // only opaque if there are no maximized windows on this screen
    readonly property bool showingStartupFeedback: MobileShellState.ShellDBusObject.startupFeedbackModel.activeWindowIsStartupFeedback && startupFeedbackColorAnimation.visible && windowMaximizedTracker.windowCount === 1
    readonly property bool opaqueBar: (windowMaximizedTracker.showingWindow || isCurrentWindowFullscreen) && !showingStartupFeedback
    readonly property alias isCurrentWindowFullscreen: windowMaximizedTracker.isCurrentWindowFullscreen
    readonly property bool fullscreen: isCurrentWindowFullscreen || (ShellSettings.Settings.autoHidePanelsEnabled && opaqueBar)

    WindowPlugin.WindowMaximizedTracker {
        id: windowMaximizedTracker
        screenGeometry: Plasmoid.containment.screenGeometry

        onShowingWindowChanged: {
            if (windowMaximizedTracker.showingWindow && MobileShellState.ShellDBusClient.isTaskSwitcherVisible && (ShellSettings.Settings.autoHidePanelsEnabled || fullscreen)) {
                navigationPanel.offset = root.navigationPanelHeight;
            }
        }
    }

    MobileShell.StartupFeedbackPanelFill {
        id: startupFeedbackColorAnimation
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        fullHeight: root.height
        screen: Plasmoid.screen
        maximizedTracker: windowMaximizedTracker

        visible: !root.fullscreen
    }

    Rectangle {
        id: navigationPanel
        anchors.fill: parent
        // contrasting colour
        Kirigami.Theme.colorSet: root.opaqueBar ? Kirigami.Theme.Window : Kirigami.Theme.Complementary
        Kirigami.Theme.inherit: false

        color: navigationPanel.state == "default" && (Keyboards.KWinVirtualKeyboard.active || root.opaqueBar) ? Kirigami.Theme.backgroundColor : "transparent"

        property real offset: 0

        // load appropriate system navigation component
        NavigationPanelComponent {
            anchors.fill: parent
            opaqueBar: root.opaqueBar
            isVertical: root.inLandscape
            navbarState: navigationPanel.state

            transform: [
                Translate {
                    y: inLandscape ? 0 : navigationPanel.offset
                    x: inLandscape ? navigationPanel.offset : 0
                }
            ]
        }

        state: MobileShellState.ShellDBusClient.panelState
        onStateChanged: {
            if (navigationPanel.state != "hidden") {
                root.setWindowProperties();
            }
        }

        states: [
            State {
                name: "default"
                PropertyChanges {
                    target: navigationPanel; offset: 0
                }
            },
            State {
                name: "visible"
                PropertyChanges {
                    target: navigationPanel; offset: 0
                }
            },
            State {
                name: "hidden"
                PropertyChanges {
                    target: navigationPanel; offset: root.navigationPanelHeight
                }
            }
        ]

        transitions: Transition {
            SequentialAnimation {
                ParallelAnimation {
                    PropertyAnimation {
                        properties: "offset"; easing.type: navigationPanel.state === "hidden" ? Easing.InExpo : Easing.OutExpo; duration: Kirigami.Units.longDuration
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

    MobileShell.SwipeArea {
        id: swipeArea
        mode: inLandscape ? MobileShell.SwipeArea.HorizontalOnly : MobileShell.SwipeArea.VerticalOnly
        anchors.fill: navigationPanel
        enabled: navigationPanel.state == "hidden"

        function startSwipeWithPoint(point) {
            root.setWindowProperties();
            resetAn.stop();
            dragEffect.startPoint = inLandscape ? point.y - Screen.height / 2 : point.x - Screen.width / 2;
            dragEffect.sidePoint = 0
            dragEffect.offsetPoint = 0;
        }

        function updateOffset(offsetX, offsetY) {
            dragEffect.sidePoint = inLandscape ? offsetY : offsetX;
            dragEffect.offsetPoint = Math.min(0, inLandscape ? offsetX : offsetY);
            if (dragEffect.offsetPoint < -Kirigami.Units.gridUnit * 5 && navigationPanel.state == "hidden") {
                swipeArea.resetSwipe();
                resetAn.restart();
                haptics.buttonVibrate();
                MobileShellState.ShellDBusClient.panelState = "visible";
            }
        }

        onSwipeStarted: (point) => startSwipeWithPoint(point)
        onSwipeEnded:  resetAn.start()
        onSwipeMove: (totalDeltaX, totalDeltaY, deltaX, deltaY) => updateOffset(totalDeltaX, totalDeltaY);

        onPressedChanged: {
            if (!pressed && dragEffect.offsetPoint == 0) {
                haptics.buttonVibrate();
                MobileShellState.ShellDBusClient.panelState = "visible";
            }
        }

        NumberAnimation {
            id: resetAn
            running: false
            target: dragEffect
            property: "offsetPoint"
            to: 0
            duration: Kirigami.Units.longDuration * 1.5
            easing.type: Easing.OutExpo
            onRunningChanged: {
                if (!running && navigationPanel.state == "hidden") {
                    root.setWindowProperties();
                }
            }
        }

        MobileShell.ScreenEdgeDragEffect {
            id: dragEffect

            offsetLimit: root.inLandscape ? swipeArea.width : swipeArea.height
            isHorizontal: root.inLandscape

            states: [
                State {
                    name: "vertical"
                    when: !root.inLandscape
                    AnchorChanges {
                        target: dragEffect
                        anchors.right: undefined
                        anchors.bottom: swipeArea.bottom
                        anchors.horizontalCenter: swipeArea.horizontalCenter
                        anchors.verticalCenter: undefined
                    }
                },
                State {
                    name: "horizontal"
                    when: root.inLandscape
                    AnchorChanges {
                        target: dragEffect
                        anchors.right: swipeArea.right
                        anchors.bottom: undefined
                        anchors.horizontalCenter: undefined
                        anchors.verticalCenter: swipeArea.verticalCenter
                    }
                }
            ]
        }
    }
}
