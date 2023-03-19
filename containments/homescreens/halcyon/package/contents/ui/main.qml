// SPDX-FileCopyrightText: 2022-2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick
import QtQuick.Window
import QtQuick.Layouts

import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents

import org.kde.plasma.private.mobileshell as MobileShell
import org.kde.plasma.private.mobileshell.state as MobileShellState
import org.kde.private.mobile.homescreen.halcyon as Halcyon
import org.kde.plasma.private.mobileshell.windowplugin as WindowPlugin

MobileShell.HomeScreen {
    id: root

    onResetHomeScreenPosition: {
        homescreen.triggerHomescreen();
    }
    
    onHomeTriggered: {
        search.close();
    }
    
    Component.onCompleted: {
        Halcyon.ApplicationListModel.loadApplications();
        Halcyon.PinnedModel.applet = plasmoid.nativeInterface;
        forceActiveFocus();
    }
    
    Rectangle {
        id: darkenBackground
        color: root.overlayShown ? 'transparent' : (homescreen.page == 1 ? Qt.rgba(0, 0, 0, 0.7) : Qt.rgba(0, 0, 0, 0.2))
        anchors.fill: parent
        z: -1
        Behavior on color { 
            ColorAnimation { duration: PlasmaCore.Units.longDuration } 
        }
    }
    
    Plasmoid.onActivated: {
        // there's a couple of steps:
        // - minimize windows (only if we are in an app)
        // - open app drawer
        // - close app drawer and, if necessary, restore windows
        if (!WindowPlugin.WindowUtil.isShowingDesktop && WindowPlugin.WindowMaximizedTracker.showingWindow || search.isOpen) {
            // Always close action drawer
            if (MobileShellState.Shell.actionDrawerVisible) {
                MobileShellState.Shell.closeActionDrawer();
            }

            // Always close the search widget as well
            if (search.isOpen) {
                search.close();
            }

            homescreen.page = 0;

            WindowPlugin.WindowUtil.isShowingDesktop = true;
        } else if (homescreen.page == 0) {
            homescreen.page = 1;
        } else {
            WindowPlugin.WindowUtil.isShowingDesktop = false;
            homescreen.page = 0;
        }
    }
    
    // homescreen component
    contentItem: Item {
        HomeScreen {
            id: homescreen
            anchors.fill: parent
            
            topMargin: root.topMargin
            bottomMargin: root.bottomMargin
            leftMargin: root.leftMargin
            rightMargin: root.rightMargin

            // make the homescreen not interactable when task switcher or startup feedback is on
            interactive: !root.overlayShown
            searchWidget: search
        }
        
        // search component
        MobileShell.KRunnerWidget {
            id: search
            anchors.fill: parent
            visible: openFactor > 0
            
            topMargin: root.topMargin
            bottomMargin: root.bottomMargin
            leftMargin: root.leftMargin
            rightMargin: root.rightMargin
        }
    }
}


