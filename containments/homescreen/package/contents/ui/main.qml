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
        HomeScreenComponents.ApplicationListModel.maxFavoriteCount = Math.max(4, Math.floor(Math.min(width, height) / homeScreen.homeScreenContents.favoriteStrip.cellWidth));
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
            homeScreen.homeScreenState.animateGoToPageIndex(0, PlasmaCore.Units.longDuration);
            homeScreen.homeScreenState.closeAppDrawer();
        }
        
        function onSnapHomeScreenPosition() {
            if (lastRequestedPosition < 0) {
                homeScreen.homeScreenState.openAppDrawer();
            } else {
                homeScreen.homeScreenState.closeAppDrawer();
            }
        }
        
        function onRequestRelativeScroll(pos) {
            // TODO
            //homeScreen.appDrawer.offset -= pos.y;
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
        // load homescreen containment
        for (let i = 0; i < plasmoid.applets.length; ++i) {
            // TODO check if this applet is actually a homescreen containment (X-Plasma-Provides)
            addApplet(plasmoid.applets[i]);
        }

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
    
    Containment.onAppletAdded: {
        // TODO check if this applet is actually a homescreen containment (X-Plasma-Provides)
        addApplet(applet);
    }
    
    Plasmoid.onActivated: {
        console.log("Triggered!", plasmoid.nativeInterface.showingDesktop)
        
        // there's a couple of steps:
        // - minimize windows
        // - open app drawer
        // - restore windows
        if (!plasmoid.nativeInterface.showingDesktop) {
            plasmoid.nativeInterface.showingDesktop = true;
        } else if (homeScreen.homeScreenState.currentView === MobileShell.HomeScreenState.PageView) {
            homeScreen.homeScreenState.openAppDrawer()
        } else {
            plasmoid.nativeInterface.showingDesktop = false
            homeScreen.homeScreenState.closeAppDrawer()
        }
    }
    
    function addApplet(applet) {
        console.log("Homescreen containment loaded applet: " + applet + " " + applet.title);
        homeScreen = applet;
        applet.parent = homeScreenContainer;
        applet.anchors.fill = homeScreenContainer;
        applet.visible = true;
    }
    
    property var homeScreen
    
    // homescreen component
    Item {
        id: homeScreenContainer
        anchors.fill: parent
        opacity: homeScreenOpacity * (1 - searchWidget.openFactor)
        
        // make the homescreen not interactable when task switcher or startup feedback is on
        //interactive: !taskSwitcher.visible && !startupFeedback.visible
        
        // control the opacity of both the search and homescreen components
        property real homeScreenOpacity: 1
        NumberAnimation on homeScreenOpacity {
            id: opacityAnimation
            duration: PlasmaCore.Units.longDuration
        }
    }
        
    // search component
    MobileShell.KRunnerWidget {
        id: searchWidget
        anchors.fill: parent
        
        opacity: homeScreenContainer.homeScreenOpacity
        visible: openFactor > 0
    }
    
    Connections {
        target: homeScreen.homeScreenState
        
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

    TaskManager.VirtualDesktopInfo {
        id: virtualDesktopInfo
    }

    TaskManager.ActivityInfo {
        id: activityInfo
    }
    
    MobileShell.TaskSwitcher {
        id: taskSwitcher
        
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
                    homeScreenContainer.homeScreenOpacity = 0;
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
        anchors.fill: parent
    }
}

