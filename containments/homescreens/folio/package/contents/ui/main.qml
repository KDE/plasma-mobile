/*
 *  SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
 *  SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Layouts 1.1

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents

import org.kde.plasma.private.mobileshell 1.0 as MobileShell
import org.kde.plasma.private.mobileshell.state 1.0 as MobileShellState
import org.kde.phone.homescreen.default 1.0 as HomeScreenLib

MobileShell.HomeScreen {
    id: root
    width: 640
    height: 480

    onResetHomeScreenPosition: {
        homescreen.homeScreenState.animateGoToPageIndex(0, PlasmaCore.Units.longDuration);
        homescreen.homeScreenState.closeAppDrawer();
    }
    
    onHomeTriggered: {
        searchWidget.close();
    }
    
    property bool componentComplete: false
    
    Component.onCompleted: {
        HomeScreenLib.ApplicationListModel.load();
        HomeScreenLib.DesktopModel.load();
        
        // ensure the gestures work immediately on load
        forceActiveFocus();
    }
    
    Plasmoid.onActivated: {       
        // there's a couple of steps:
        // - minimize windows (only if we are in an app)
        // - open app drawer
        // - close app drawer and, if necessary, restore windows
        if (!plasmoid.nativeInterface.showingDesktop && !MobileShellState.Shell.homeScreenVisible
            || MobileShellState.Shell.actionDrawerVisible 
            || searchWidget.isOpen
        ) {
            // Always close action drawer
            if (MobileShellState.Shell.actionDrawerVisible) {
                MobileShellState.Shell.closeActionDrawer();
            }
            
            // Always close the search widget as well
            if (searchWidget.isOpen) {
                searchWidget.close();
            }
            
            plasmoid.nativeInterface.showingDesktop = true;
        } else if (homescreen.homeScreenState.currentView === HomeScreenState.PageView) {
            homescreen.homeScreenState.openAppDrawer();
        } else {
            plasmoid.nativeInterface.showingDesktop = false;
            homescreen.homeScreenState.closeAppDrawer();
        }
    }
    
    contentItem: Item {
        // homescreen component
        HomeScreen {
            id: homescreen
            anchors.fill: parent

            topMargin: root.topMargin
            bottomMargin: root.bottomMargin
            leftMargin: root.leftMargin
            rightMargin: root.rightMargin

            opacity: (1 - searchWidget.openFactor)

            // make the homescreen not interactable when task switcher or startup feedback is on
            interactive: !root.overlayShown
        }
        
        // search component
        MobileShell.KRunnerWidget {
            id: searchWidget
            anchors.fill: parent
            
            visible: openFactor > 0

            topMargin: root.topMargin
            bottomMargin: root.bottomMargin
            leftMargin: root.leftMargin
            rightMargin: root.rightMargin
            
            // close search component when task switcher is shown or hidden
            Connections {
                target: MobileShellState.HomeScreenControls.taskSwitcher
                function onVisibleChanged() {
                    searchWidget.close();
                }
            }
        }
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
    
    // listen to app launch errors
    Connections {
        target: HomeScreenLib.ApplicationListModel
        function onLaunchError(msg) {
            MobileShellState.Shell.closeAppLaunchAnimation()
        }
    }
}

