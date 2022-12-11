/*
 * SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 * SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Window 2.15

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.plasmoid 2.0
import org.kde.taskmanager 0.1 as TaskManager

import org.kde.plasma.private.mobileshell 1.0 as MobileShell
import org.kde.plasma.private.mobileshell.state 1.0 as MobileShellState

/**
 * The base homescreen component, implementing features that simplify
 * homescreen implementation.
 */
Item {
    id: root

    /**
     * Emitted when an action is triggered to open the homescreen.
     */
    signal homeTriggered()
    
    /**
     * Emitted when resetting the homescreen position is requested.
     */
    signal resetHomeScreenPosition()
    
    /**
     * Emitted when moving the homescreen position is requested.
     */
    signal requestRelativeScroll(var pos)
    
    /**
     * The visual item that is the homescreen.
     */
    property alias contentItem: itemContainer.contentItem

    /**
     * Whether a component is being shown on top of the homescreen within the same
     * window.
     */
    readonly property bool overlayShown: taskSwitcher.visible || startupFeedback.visible
    
    /**
     * Margins for the homescreen, taking panels into account.
     */
    property real topMargin
    property real bottomMargin
    property real leftMargin
    property real rightMargin

    function evaluateMargins() {
        topMargin = plasmoid.availableScreenRect.y
        // add a specific check for the nav panel for now, since the gesture mode still technically has height
        bottomMargin = MobileShell.MobileShellSettings.navigationPanelEnabled ? root.height - (plasmoid.availableScreenRect.y + plasmoid.availableScreenRect.height) : 0;
        leftMargin = plasmoid.availableScreenRect.x
        rightMargin = root.width - (plasmoid.availableScreenRect.x + plasmoid.availableScreenRect.width)
    }

    Connections {
        target: plasmoid

        // avoid binding loops with root.height and root.width changing along with the availableScreenRect
        function onAvailableScreenRectChanged() {
            Qt.callLater(() => root.evaluateMargins());
        }
    }

    //BEGIN API implementation

    Connections {
        target: MobileShellState.HomeScreenControls
        
        function onOpenHomeScreen() {
            if (!MobileShell.WindowUtil.allWindowsMinimized) {
                itemContainer.zoomIn();
            }
            
            MobileShellState.HomeScreenControls.resetHomeScreenPosition();
            taskSwitcher.visible = false; // will trigger homescreen open
            taskSwitcher.minimizeAll();
            
            root.homeTriggered();
        }
        
        function onResetHomeScreenPosition() {
            root.resetHomeScreenPosition();
        }
        
        function onRequestRelativeScroll(pos) {
            // TODO
            //homescreen.appDrawer.offset -= pos.y;
            //lastRequestedPosition = pos.y;
        }
        
        function onOpenAppLaunchAnimation(splashIcon, title, x, y, sourceIconSize) {
            startupFeedback.open(splashIcon, title, x, y, sourceIconSize);
        }
        
        function onCloseAppLaunchAnimation() {
            startupFeedback.close();
        }
    }
    
    Plasmoid.onScreenChanged: {
        if (plasmoid.screen == 0) {
            MobileShellState.HomeScreenControls.taskSwitcher = taskSwitcher;
            MobileShellState.HomeScreenControls.homeScreenWindow = root.Window.window;
        }
    }
    Window.onWindowChanged: {
        if (plasmoid.screen == 0) {
            MobileShellState.HomeScreenControls.homeScreenWindow = root.Window.window;
        }
    }

//END API implementation

    Component.onCompleted: {
        // determine the margins used
        evaluateMargins();

        // set API variables
        if (plasmoid.screen == 0) {
            MobileShellState.HomeScreenControls.taskSwitcher = taskSwitcher;
            MobileShellState.HomeScreenControls.homeScreenWindow = root.Window.window;
        }
    }
    
    TaskManager.VirtualDesktopInfo {
        id: virtualDesktopInfo
    }

    TaskManager.ActivityInfo {
        id: activityInfo
    }

    PlasmaCore.SortFilterModel {
        id: visibleMaximizedWindowsModel
        readonly property bool isWindowMaximized: count > 0
        
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
    
    // homescreen visual component
    MobileShell.BaseItem {
        id: itemContainer
        anchors.fill: parent
        
        // animations
        opacity: 0
        property real zoomScale: 0.8
        
        Component.onCompleted: zoomIn()
        
        function zoomIn() {
            // don't use check animationsEnabled here, so we ensure the scale and opacity is always 1 when disabled
            scaleAnim.to = 1;
            scaleAnim.restart();
            opacityAnim.to = 1;
            opacityAnim.restart();
        }
        function zoomOut() {
            if (MobileShell.MobileShellSettings.animationsEnabled) {
                scaleAnim.to = 0.8;
                scaleAnim.restart();
                opacityAnim.to = 0;
                opacityAnim.restart();
            }
        }
        
        NumberAnimation on opacity {
            id: opacityAnim
            duration: MobileShell.MobileShellSettings.animationsEnabled ? 300 : 0
            running: false
        }
        
        NumberAnimation on zoomScale {
            id: scaleAnim
            duration: MobileShell.MobileShellSettings.animationsEnabled ? 600 : 0
            running: false
            easing.type: Easing.OutExpo
        }
        
        function evaluateAnimChange() {
            // only animate if homescreen is visible
            if (!taskSwitcher.visible) {
                if (!visibleMaximizedWindowsModel.isWindowMaximized || MobileShell.WindowUtil.activeWindowIsShell) {
                    itemContainer.zoomIn();
                } else {
                    itemContainer.zoomOut();
                }
            }
        }
        
        Connections {
            target: MobileShell.WindowUtil
            function onActiveWindowIsShellChanged() {
                itemContainer.evaluateAnimChange();
            }
        }
        
        Connections {
            target: visibleMaximizedWindowsModel
            function onIsWindowMaximizedChanged() {
                itemContainer.evaluateAnimChange();
            }
        }
        
        transform: Scale { 
            origin.x: itemContainer.width / 2; 
            origin.y: itemContainer.height / 2; 
            xScale: itemContainer.zoomScale
            yScale: itemContainer.zoomScale
        }
    }
    
    // task switcher component
    MobileShell.TaskSwitcher {
        id: taskSwitcher
        z: 999999
        
        topMargin: root.topMargin
        bottomMargin: root.bottomMargin
        leftMargin: root.leftMargin
        rightMargin: root.rightMargin

        tasksModel: TaskManager.TasksModel {
            groupMode: TaskManager.TasksModel.GroupDisabled

            screenGeometry: plasmoid.screenGeometry
            sortMode: TaskManager.TasksModel.SortLastActivated

            virtualDesktop: virtualDesktopInfo.currentDesktop
            activity: activityInfo.currentActivity
        }
        
        anchors.fill: parent
        
        // hide homescreen elements to make use of wallpaper
        onVisibleChanged: {
            if (visible) {
                startupFeedback.visible = false;
                
                // hide immediately when going from homescreen
                if (!taskSwitcher.wasInActiveTask) {
                    itemContainer.opacity = 0;
                }
                itemContainer.zoomOut();
                
            } else {
                itemContainer.zoomIn();
            }
        }
    }
    
    // start app animation component
    MobileShell.StartupFeedback {
        id: startupFeedback
        z: 999999
        anchors.fill: parent
        
        // if the startup feedback closes, clear the shell's stored launching app
        onVisibleChanged: {
            if (!visible) {
                MobileShell.ShellUtil.clearLaunchingApp();
            }
        }
    }
}
