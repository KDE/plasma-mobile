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
FocusScope {
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
     * The requested opacity of homescreen elements (for opacity animations).
     */
    property real homeScreenOpacity: 1
    
    /**
     * Whether a component is being shown on top of the homescreen within the same
     * window.
     */
    property bool overlayShown: taskSwitcher.visible || startupFeedback.visible

    NumberAnimation on homeScreenOpacity {
        id: opacityAnimation
        duration: PlasmaCore.Units.longDuration
    }
    
    //BEGIN API implementation
    Connections {
        target: MobileShell.HomeScreenControls
        
        function onOpenHomeScreen() {
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
    
    // task switcher component
    TaskManager.VirtualDesktopInfo {
        id: virtualDesktopInfo
    }

    TaskManager.ActivityInfo {
        id: activityInfo
    }
    
    MobileShell.TaskSwitcher {
        id: taskSwitcher
        z: 999999
        
        tasksModel: TaskManager.TasksModel {
            groupMode: TaskManager.TasksModel.GroupDisabled

            screenGeometry: plasmoid.screenGeometry
            sortMode: TaskManager.TasksModel.SortAlpha

            virtualDesktop: virtualDesktopInfo.currentDesktop
            activity: activityInfo.currentActivity
        }

        anchors.fill: parent
        
        // hide homescreen elements to make use of wallpaper
        onVisibleChanged: {
            if (visible) {
                startupFeedback.visible = false;
                
                // only animate if going from homescreen
                if (taskSwitcher.wasInActiveTask) {
                    opacityAnimation.to = 0;
                    opacityAnimation.restart();
                } else {
                    root.homeScreenOpacity = 0;
                }
                
            } else {
                opacityAnimation.to = 1;
                opacityAnimation.restart();
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
