// SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
// SPDX-FileCopyrightText: 2021-2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick 2.4
import QtQuick.Layouts 1.1
import QtQuick.Window 2.15

import org.kde.kirigami 2.20 as Kirigami

import org.kde.taskmanager 0.1 as TaskManager
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core as PlasmaCore
import org.kde.kquickcontrolsaddons 2.0

import org.kde.plasma.private.mobileshell as MobileShell
import org.kde.plasma.private.mobileshell.shellsettingsplugin as ShellSettings
import org.kde.plasma.private.mobileshell.windowplugin as WindowPlugin
import org.kde.plasma.private.mobileshell.state as MobileShellState

ContainmentItem {
    id: root
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
    Plasmoid.status: PlasmaCore.Types.PassiveStatus // ensure that the panel never takes focus away from the running app

    // filled in by the shell (Panel.qml) with the plasma-workspace PanelView
    property var panel: null
    onPanelChanged: {
        setWindowProperties()
    }

    // filled in by the shell (Panel.qml)
    property var tabBar: null
    onTabBarChanged: {
        if (tabBar) {
            tabBar.visible = false;
        }
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
            root.panel.maximize()
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

    Component.onCompleted: setWindowProperties();

    // only opaque if there are no maximized windows on this screen
    readonly property bool showingStartupFeedback: MobileShellState.ShellDBusObject.startupFeedbackModel.activeWindowIsStartupFeedback && windowMaximizedTracker.windowCount === 1
    readonly property bool opaqueBar: windowMaximizedTracker.showingWindow && !showingStartupFeedback

    WindowPlugin.WindowMaximizedTracker {
        id: windowMaximizedTracker
        screenGeometry: Plasmoid.containment.screenGeometry
    }

    MobileShell.StartupFeedbackPanelFill {
        id: startupFeedbackColorAnimation
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        fullHeight: root.height
        screen: Plasmoid.screen
        maximizedTracker: windowMaximizedTracker
    }

    Item {
        anchors.fill: parent

        // contrasting colour
        Kirigami.Theme.colorSet: opaqueBar ? Kirigami.Theme.Window : Kirigami.Theme.Complementary
        Kirigami.Theme.inherit: false

        // load appropriate system navigation component
        NavigationPanelComponent {
            id: navigationPanel
            anchors.fill: parent
            opaqueBar: root.opaqueBar
            isVertical: root.inLandscape
        }
    }
}
