/*
 *  SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
 *  SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.4
import QtQuick.Layouts 1.1
import QtQuick.Window 2.15
import QtGraphicalEffects 1.12

import org.kde.taskmanager 0.1 as TaskManager
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kquickcontrolsaddons 2.0

import org.kde.plasma.private.nanoshell 2.0 as NanoShell
import org.kde.plasma.private.mobileshell 1.0 as MobileShell
import org.kde.plasma.private.mobileshell.state 1.0 as MobileShellState

PlasmaCore.ColorScope {
    id: root
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
    
    width: 480
    height: PlasmaCore.Units.gridUnit * 2

    // toggle visibility of navigation bar (show, or use gestures only)
    Binding {
        target: plasmoid.Window.window // assumed to be plasma-workspace "PanelView" component
        property: "visibilityMode"
        // 0 - VisibilityMode.NormalPanel
        // 3 - VisibilityMode.WindowsGoBelow
        value: MobileShell.MobileShellSettings.navigationPanelEnabled ? 0 : 3
    }

    // we have the following scenarios:
    // - system is in landscape orientation & nav panel is enabled (panel on right)
    // - system is in landscape orientation & gesture mode is enabled (panel on bottom)
    // - system is in portrait orientation (panel on bottom)
    readonly property bool inLandscape: Screen.width > Screen.height;
    readonly property bool isInLandscapeNavPanelMode: inLandscape && MobileShell.MobileShellSettings.navigationPanelEnabled

    readonly property real navigationPanelHeight: PlasmaCore.Units.gridUnit * 2
    readonly property real gesturePanelHeight: 8

    readonly property real intendedWindowThickness: MobileShell.MobileShellSettings.navigationPanelEnabled ? navigationPanelHeight : gesturePanelHeight
    readonly property real intendedWindowLength: isInLandscapeNavPanelMode ? Screen.height : Screen.width
    readonly property real intendedWindowOffset: isInLandscapeNavPanelMode ? MobileShellState.TopPanelControls.panelHeight : 0; // offset for top panel
    readonly property int intendedWindowLocation: isInLandscapeNavPanelMode ? PlasmaCore.Types.RightEdge : PlasmaCore.Types.BottomEdge

    onIntendedWindowThicknessChanged: plasmoid.Window.window.thickness = intendedWindowThickness
    onIntendedWindowLengthChanged: maximizeTimer.restart() // ensure it always takes up the full length of the screen
    onIntendedWindowOffsetChanged: plasmoid.Window.window.offset = intendedWindowOffset
    onIntendedWindowLocationChanged: locationChangeTimer.restart()

    // use a timer so we don't have to maximize for every single pixel
    // - improves performance if the shell is run in a window, and can be resized
    Timer {
        id: maximizeTimer
        running: false
        interval: 100
        onTriggered: {
            // maximize first, then we can apply offsets (otherwise they are overridden)
            plasmoid.Window.window.maximize()
            plasmoid.Window.window.offset = intendedWindowOffset;
        }
    }

    // use a timer so that rotation events are faster (offload the panel movement to later, after everything is figured out)
    Timer {
        id: locationChangeTimer
        running: false
        interval: 100
        onTriggered: plasmoid.Window.window.location = intendedWindowLocation
    }

    function setWindowProperties() {
        // plasmoid.Window.window is assumed to be plasma-workspace "PanelView" component
        plasmoid.Window.window.maximize(); // maximize first, then we can apply offsets (otherwise they are overridden)
        plasmoid.Window.window.offset = intendedWindowOffset;
        plasmoid.Window.window.thickness = intendedWindowThickness;
        plasmoid.Window.window.location = intendedWindowLocation;
    }
    
    Connections {
        target: plasmoid.Window.window

        // HACK: There seems to be some component that overrides our initial bindings for the panel,
        //   which is particularly problematic on first start (since the panel is misplaced)
        // - We set an event to override any attempts to override our bindings.
        function onLocationChanged() {
            if (plasmoid.Window.window.location !== root.intendedWindowLocation) {
                root.setWindowProperties();
            }
        }

        function onThicknessChanged() {
            if (plasmoid.Window.window.thickness !== root.intendedWindowThickness) {
                root.setWindowProperties();
            }
        }
    }

    Component.onCompleted: setWindowProperties();

    TaskManager.VirtualDesktopInfo {
        id: virtualDesktopInfo
    }

    TaskManager.ActivityInfo {
        id: activityInfo
    }

    PlasmaCore.SortFilterModel {
        id: visibleMaximizedWindowsModel
        filterRole: 'IsMinimized'
        filterRegExp: 'false'
        sourceModel: TaskManager.TasksModel {
            id: tasksModel
            filterByVirtualDesktop: true
            filterByActivity: true
            filterNotMaximized: true
            filterByScreen: true
            filterHidden: true

            virtualDesktop: virtualDesktopInfo.currentDesktop
            activity: activityInfo.currentActivity

            groupMode: TaskManager.TasksModel.GroupDisabled
        }
    }

    // only opaque if there are no maximized windows on this screen
    readonly property bool opaqueBar: visibleMaximizedWindowsModel.count > 0
    
    // contrasting colour
    colorGroup: opaqueBar ? PlasmaCore.Theme.NormalColorGroup : PlasmaCore.Theme.ComplementaryColorGroup
    
    // bottom navigation panel component
    Component {
        id: navigationPanel 
        NavigationPanelComponent {
            taskSwitcher: MobileShellState.HomeScreenControls.taskSwitcher
            opaqueBar: root.opaqueBar
        }
    }
    
    // bottom navigation gesture area component
    Component {
        id: navigationGesture 
        MobileShell.NavigationGestureArea {
            taskSwitcher: MobileShellState.HomeScreenControls.taskSwitcher
        }
    }
    
    // load appropriate system navigation component
    Loader {
        id: navigationLoader
        anchors.fill: parent
        sourceComponent: MobileShell.MobileShellSettings.navigationPanelEnabled ? navigationPanel : navigationGesture
    }
}
