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
    property bool overlayShown: taskSwitcher.visible || startupFeedback.visible
    
    //BEGIN API implementation
    Connections {
        target: MobileShell.HomeScreenControls
        
        function onOpenHomeScreen() {
            if (!MobileShell.WindowUtil.allWindowsMinimized) {
                itemContainer.zoomIn();
            }
            
            MobileShell.HomeScreenControls.resetHomeScreenPosition();
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
            MobileShell.HomeScreenControls.taskSwitcher = taskSwitcher;
            MobileShell.HomeScreenControls.homeScreenWindow = root.Window.window;
        }
    }
    Window.onWindowChanged: {
        if (plasmoid.screen == 0) {
            MobileShell.HomeScreenControls.homeScreenWindow = root.Window.window;
        }
    }

//END API implementation
    
    Component.onCompleted: {
        // set API variables
        if (plasmoid.screen == 0) {
            MobileShell.HomeScreenControls.taskSwitcher = taskSwitcher;
            MobileShell.HomeScreenControls.homeScreenWindow = root.Window.window;
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
            scaleAnim.to = 1;
            scaleAnim.restart();
            opacityAnim.to = 1;
            opacityAnim.restart();
        }
        function zoomOut() {
            scaleAnim.to = 0.8;
            scaleAnim.restart();
            opacityAnim.to = 0;
            opacityAnim.restart();
        }
        
        NumberAnimation on opacity {
            id: opacityAnim
            duration: 300
            running: false
        }
        
        NumberAnimation on zoomScale {
            id: scaleAnim
            duration: 600
            running: false
            easing.type: Easing.OutExpo
        }
        
        Connections {
            target: MobileShell.WindowUtil
            
            function onActiveWindowIsShellChanged() {
                // only animate if homescreen is visible
                if (!taskSwitcher.visible) {
                    if (MobileShell.WindowUtil.activeWindowIsShell) {
                        itemContainer.zoomIn();
                    } else {
                        itemContainer.zoomOut();
                    }
                }
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
        
        tasksModel: TaskManager.TasksModel {
            groupMode: TaskManager.TasksModel.GroupDisabled

            screenGeometry: plasmoid.screenGeometry
            sortMode: TaskManager.TasksModel.SortLastActivated

            virtualDesktop: virtualDesktopInfo.currentDesktop
            activity: activityInfo.currentActivity
        }

        TaskManager.VirtualDesktopInfo {
            id: virtualDesktopInfo
        }
        
        TaskManager.ActivityInfo {
            id: activityInfo
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
    }
}
