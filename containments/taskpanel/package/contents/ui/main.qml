// SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
// SPDX-FileCopyrightText: 2021-2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import org.kde.plasma.plasmoid 2.0
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

ContainmentItem {
    id: root
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground

    // toggle visibility of navigation bar (show, or use gestures only)
    Binding {
        target: Plasmoid.Window.window // assumed to be plasma-workspace "PanelView" component
        property: "visibilityMode"
        // 0 - VisibilityMode.NormalPanel
        // 2 - VisibilityMode.LetWindowsCover HACK: TODO one day we make delete the panel component instead of making it invisible in gesture-only mode
        value: ShellSettings.Settings.navigationPanelEnabled ? 0 : 2
    }

    // we have the following scenarios:
    // - system is in landscape orientation & nav panel is enabled (panel on right)
    // - system is in landscape orientation & gesture mode is enabled (panel on bottom)
    // - system is in portrait orientation (panel on bottom)
    readonly property bool inLandscape: Screen.width > Screen.height;
    readonly property bool isInLandscapeNavPanelMode: inLandscape && ShellSettings.Settings.navigationPanelEnabled

    readonly property real navigationPanelHeight: Kirigami.Units.gridUnit * 2

    readonly property real intendedWindowThickness: navigationPanelHeight
    readonly property real intendedWindowLength: isInLandscapeNavPanelMode ? Screen.height : Screen.width
    readonly property real intendedWindowOffset: isInLandscapeNavPanelMode ? MobileShell.Constants.topPanelHeight : 0; // offset for top panel
    readonly property int intendedWindowLocation: isInLandscapeNavPanelMode ? PlasmaCore.Types.RightEdge : PlasmaCore.Types.BottomEdge

    onIntendedWindowLengthChanged: maximizeTimer.restart() // ensure it always takes up the full length of the screen
    onIntendedWindowLocationChanged: locationChangeTimer.restart()
    onIntendedWindowOffsetChanged: {
        if (plasmoid && Plasmoid.Window.window) {
            Plasmoid.Window.window.offset = intendedWindowOffset;
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
            Plasmoid.Window.window.maximize()
            Plasmoid.Window.window.offset = intendedWindowOffset;
        }
    }

    // use a timer so that rotation events are faster (offload the panel movement to later, after everything is figured out)
    Timer {
        id: locationChangeTimer
        running: false
        interval: 100
        onTriggered: Plasmoid.Window.window.location = intendedWindowLocation
    }

    function setWindowProperties() {
        // Plasmoid.Window.window is assumed to be plasma-workspace "PanelView" component
        if (plasmoid && Plasmoid.Window.window) {
            Plasmoid.Window.window.maximize(); // maximize first, then we can apply offsets (otherwise they are overridden)
            Plasmoid.Window.window.offset = intendedWindowOffset;
            Plasmoid.Window.window.thickness = navigationPanelHeight;
            Plasmoid.Window.window.location = intendedWindowLocation;
        }
    }

    Connections {
        target: Plasmoid.Window.window

        // HACK: There seems to be some component that overrides our initial bindings for the panel,
        //   which is particularly problematic on first start (since the panel is misplaced)
        // - We set an event to override any attempts to override our bindings.
        function onLocationChanged() {
            if (Plasmoid.Window.window.location !== root.intendedWindowLocation) {
                root.setWindowProperties();
            }
        }

        function onThicknessChanged() {
            if (Plasmoid.Window.window.thickness !== root.intendedWindowThickness) {
                root.setWindowProperties();
            }
        }
    }

    Component.onCompleted: setWindowProperties();

    // only opaque if there are no maximized windows on this screen
    readonly property bool opaqueBar: WindowPlugin.WindowMaximizedTracker.showingWindow

    Item {
        anchors.fill: parent

        // contrasting colour
        Kirigami.Theme.colorSet: opaqueBar ? Kirigami.Theme.Window : Kirigami.Theme.Complementary
        Kirigami.Theme.inherit: false

        // load appropriate system navigation component
        Loader {
            id: navigationLoader
            active: ShellSettings.Settings.navigationPanelEnabled
            anchors.fill: parent
            sourceComponent: NavigationPanelComponent {
                opaqueBar: root.opaqueBar
            }
        }
    }
}
