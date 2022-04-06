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
    
    function recalculateMaxFavoriteCount() {
        if (!componentComplete) {
            return;
        }
        MobileShell.ApplicationListModel.maxFavoriteCount = Math.max(4, Math.floor(Math.min(width, height) / homescreen.homeScreenContents.favoriteStrip.cellWidth));
    }

    onWidthChanged: recalculateMaxFavoriteCount()
    onHeightChanged: recalculateMaxFavoriteCount()
    
    Component.onCompleted: {
        // ApplicationListModel doesn't have a plasmoid as is not the one that should be doing writing
        MobileShell.ApplicationListModel.loadApplications();
        MobileShell.FavoritesModel.applet = plasmoid;
        MobileShell.FavoritesModel.loadApplications();

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
    
    // homescreen component
    HomeScreen {
        id: homescreen
        anchors.fill: parent
        opacity: root.homeScreenOpacity * (1 - searchWidget.openFactor)
        
        // make the homescreen not interactable when task switcher or startup feedback is on
        interactive: !root.overlayShown
    }
        
    // search component
    MobileShell.KRunnerWidget {
        id: searchWidget
        anchors.fill: parent
        
        opacity: root.homeScreenOpacity
        visible: openFactor > 0
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
        target: MobileShell.ApplicationListModel
        function onLaunchError(msg) {
            MobileShell.HomeScreenControls.closeAppLaunchAnimation()
        }
    }
}

