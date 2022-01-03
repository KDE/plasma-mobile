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
        HomeScreenComponents.ApplicationListModel.maxFavoriteCount = Math.max(4, Math.floor(Math.min(width, height) / homescreen.homeScreenContents.favoriteStrip.cellWidth));
    }
    
    function triggerHomeScreen() {
        MobileShell.HomeScreenControls.resetHomeScreenPosition();
        taskSwitcher.visible = false; // will trigger homescreen open
        searchWidget.close();
        taskSwitcher.minimizeAll();
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
            homescreen.homeScreenState.animateGoToPageIndex(0, PlasmaCore.Units.longDuration);
            homescreen.homeScreenState.closeAppDrawer();
        }
        
        function onSnapHomeScreenPosition() {
            if (lastRequestedPosition < 0) {
                homescreen.homeScreenState.openAppDrawer();
            } else {
                homescreen.homeScreenState.closeAppDrawer();
            }
        }
        
        function onRequestRelativeScroll(pos) {
            // TODO
            //homescreen.appDrawer.offset -= pos.y;
            //lastRequestedPosition = pos.y;
        }
        
        function onOpenAppAnimation(splashIcon, title, x, y, sourceIconSize) {
            startupFeedback.open(splashIcon, title, x, y, sourceIconSize);
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
        
        // there's a couple of steps:
        // - minimize windows
        // - open app drawer
        // - restore windows
        if (!plasmoid.nativeInterface.showingDesktop) {
            plasmoid.nativeInterface.showingDesktop = true;
        } else if (homescreen.homeScreenState.currentView === MobileShell.HomeScreenState.PageView) {
            homescreen.homeScreenState.openAppDrawer()
        } else {
            plasmoid.nativeInterface.showingDesktop = false
            homescreen.homeScreenState.closeAppDrawer()
        }
    }
    
    // control the opacity of both the search and homescreen components
    property real homeScreenOpacity: 1
    NumberAnimation on homeScreenOpacity {
        id: opacityAnimation
        duration: PlasmaCore.Units.longDuration
    }
    
    // homescreen component
    HomeScreenComponents.HomeScreen {
        id: homescreen
        anchors.fill: parent
        opacity: root.homeScreenOpacity * (1 - searchWidget.openFactor)
        
        // make the homescreen not interactable when task switcher or startup feedback is on
        interactive: !taskSwitcher.visible && !startupFeedback.visible
        
    }
        
    // search component
    MobileShell.KRunnerWidget {
        id: searchWidget
        anchors.fill: parent
        
        opacity: root.homeScreenOpacity
        visible: openFactor > 0
        onOpenFactorChanged: homescreen.opacity = 1 - openFactor;
    }
    
    Connections {
        target: homescreen.homeScreenState
        
        function onSwipeDownGestureBegin() {
            searchWidget.startGesture();
        }
        function onSwipeDownGestureEnd() {
            searchWidget.endGesture();
        }
        function onSwipeDownGestureOffset(offset) {
            searchWidget.updateGestureOffset(-offset);
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
    
    // start app animation
    MobileShell.StartupFeedback {
        id: startupFeedback
        anchors.fill: parent
    }
}

