/*
 *  SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
 *  SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Layouts 1.1

import org.kde.taskmanager 0.1 as TaskManager
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents

import org.kde.plasma.private.mobilehomescreencomponents 0.1 as HomeScreenComponents
import org.kde.plasma.private.mobileshell 1.0 as MobileShell

FocusScope {
    id: root
    width: 640
    height: 480

//BEGIN functions

    function recalculateMaxFavoriteCount() {
        if (!componentComplete) {
            return;
        }
        HomeScreenComponents.ApplicationListModel.maxFavoriteCount = Math.max(4, Math.floor(Math.min(width, height) / homescreen.homeScreenContents.appletsLayout.cellWidth));
    }
    
    function triggerHomeScreen() {
        taskSwitcher.minimizeAll();
        MobileShell.HomeScreenControls.resetHomeScreenPosition();
        taskSwitcher.visible = false; // will trigger homescreen open
    }

//END functions

//BEGIN API implementation
    Connections {
        target: MobileShell.HomeScreenControls
        
        property real lastRequestedPosition: 0
        
        function onOpenHomeScreen() {
            root.triggerHomeScreen();
        }
        
        function onResetHomeScreenPosition() {
            homescreen.flickablePages.scrollToPage(0);
            homescreen.appDrawer.close();
        }
        
        function onSnapHomeScreenPosition() {
            if (lastRequestedPosition < 0) {
                homescreen.appDrawer.open();
            } else {
                homescreen.appDrawer.close();
            }
        }
        
        function onRequestRelativeScroll(pos) {
            homescreen.appDrawer.offset -= pos.y;
            lastRequestedPosition = pos.y;
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

    property bool componentComplete: false
    onWidthChanged: recalculateMaxFavoriteCount()
    onHeightChanged: recalculateMaxFavoriteCount()
    
    Component.onCompleted: {
        // ApplicationListModel doesn't have a plasmoid as is not the one that should be doing writing
        HomeScreenComponents.ApplicationListModel.loadApplications();
        HomeScreenComponents.FavoritesModel.applet = plasmoid;
        HomeScreenComponents.FavoritesModel.loadApplications();

        // set API variables
        if (plasmoid.screen == 0) {
            MobileShell.HomeScreenControls.taskSwitcher = taskSwitcher;
            MobileShell.HomeScreenControls.homeScreenWindow = root.Window.window;
        }
        componentComplete = true;
        recalculateMaxFavoriteCount()
        
        // ensure the gestures work immediately on load
        forceActiveFocus();
    }
    
    Plasmoid.onActivated: {
        console.log("Triggered!", plasmoid.nativeInterface.showingDesktop)
        homescreen.activate();
    }
    
    // homescreen component
    HomeScreen {
        id: homescreen
        anchors.fill: parent
     
        opacity: 1
        NumberAnimation on opacity {
            id: opacityAnimation
            duration: PlasmaCore.Units.longDuration
        }
    }
    
    // task switcher component
    TaskManager.TasksModel {
        id: tasksModel
        groupMode: TaskManager.TasksModel.GroupDisabled

        screenGeometry: plasmoid.screenGeometry
        sortMode: TaskManager.TasksModel.SortAlpha

        virtualDesktop: virtualDesktopInfo.currentDesktop
        activity: activityInfo.currentActivity
    }

    TaskManager.VirtualDesktopInfo {
        id: virtualDesktopInfo
    }

    TaskManager.ActivityInfo {
        id: activityInfo
    }
    
    MobileShell.TaskSwitcher {
        id: taskSwitcher
        model: tasksModel

        anchors.fill: parent
        
        // hide homescreen elements to make use of wallpaper
        onVisibleChanged: {
            if (visible) {
                // only animate if going from homescreen
                if (taskSwitcher.wasInActiveTask) {
                    opacityAnimation.to = 0;
                    opacityAnimation.restart();
                } else {
                    homescreen.opacity = 0;
                }
                
            } else {
                opacityAnimation.to = 1;
                opacityAnimation.restart();
            }
        }
    }
}

