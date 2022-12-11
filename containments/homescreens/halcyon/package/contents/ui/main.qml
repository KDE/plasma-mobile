// SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Layouts 1.1

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents

import org.kde.plasma.private.mobileshell 1.0 as MobileShell
import org.kde.plasma.private.mobileshell.state 1.0 as MobileShellState
import org.kde.phone.homescreen.halcyon 1.0 as Halcyon

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
        Halcyon.PinnedModel.load();
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
        if (!plasmoid.nativeInterface.showingDesktop && !MobileShellState.Shell.homeScreenVisible
            || MobileShellState.Shell.actionDrawerVisible 
            || search.isOpen
        ) {
            // Always close action drawer
            if (MobileShellState.Shell.actionDrawerVisible) {
                MobileShellState.Shell.closeActionDrawer();
            }
            
            // Always close the search widget as well
            if (search.isOpen) {
                search.close();
            }
            
            plasmoid.nativeInterface.showingDesktop = true;
        } else if (homescreen.page == 0) {
            homescreen.page = 1;
        } else {
            plasmoid.nativeInterface.showingDesktop = false;
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

             // close search component when task switcher is shown or hidden
            Connections {
                target: MobileShellState.HomeScreenControls.taskSwitcher
                function onVisibleChanged() {
                    search.close();
                }
            }
        }
    }
}


