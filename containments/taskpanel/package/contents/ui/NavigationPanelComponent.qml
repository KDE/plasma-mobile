/*
 *  SPDX-FileCopyrightText: 2021-2022 Devin Lin <devin@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.4
import QtQuick.Layouts 1.1
import QtQuick.Window 2.15

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

import org.kde.plasma.private.mobileshell 1.0 as MobileShell

MobileShell.NavigationPanel {
    id: root
    property bool appIsShown: !plasmoid.nativeInterface.allMinimized
    
    // background is:
    // - opaque if an app is shown
    // - translucent if the task switcher is open
    // - transparent if on the homescreen
    backgroundColor: {
        if (root.taskSwitcher.visible) {
            return Qt.rgba(0, 0, 0, 0.1);
        } else {
            return appIsShown ? PlasmaCore.ColorScope.backgroundColor : "transparent";
        }
    }
    foregroundColorGroup: (!root.taskSwitcher.visible && appIsShown) ? PlasmaCore.Theme.NormalColorGroup : PlasmaCore.Theme.ComplementaryColorGroup
    shadow: !appIsShown
        
    // do not enable drag gesture when task switcher is already open
    // also don't disable drag gesture mid-drag
    dragGestureEnabled: !root.taskSwitcher.visible || root.taskSwitcher.taskSwitcherState.currentlyBeingOpened
    
    // ~~~~
    // navigation panel actions
    
    // toggle task switcher button
    leftAction: MobileShell.NavigationPanelAction {
        id: taskSwitcherAction
        
        enabled: (root.taskSwitcher.tasksCount > 0) || root.taskSwitcher.visible
        iconSource: "mobile-task-switcher"
        iconSizeFactor: 0.75
        
        onTriggered: {
            plasmoid.nativeInterface.showDesktop = false;
            
            if (!root.taskSwitcher.visible) {
                root.taskSwitcher.show(true);
            } else {
                // when task switcher is open
                if (root.taskSwitcher.taskSwitcherState.wasInActiveTask) {
                    // restore active window
                    root.taskSwitcher.activateWindow(taskSwitcher.taskSwitcherState.currentTaskIndex);
                } else {
                    root.taskSwitcher.hide();
                }
            }
        }
    }
    
    // home button
    middleAction: MobileShell.NavigationPanelAction {
        id: homeAction
        
        enabled: true
        iconSource: "start-here-kde"
        iconSizeFactor: 1
        
        onTriggered: {
            MobileShell.HomeScreenControls.openHomeScreen();
            plasmoid.nativeInterface.allMinimizedChanged();
        }
    }
    
    // close app/keyboard button
    rightAction: MobileShell.NavigationPanelAction {
        id: closeAppAction
        
        enabled: MobileShell.KWinVirtualKeyboard.visible || root.taskSwitcher.visible || plasmoid.nativeInterface.hasCloseableActiveWindow
        iconSource: MobileShell.KWinVirtualKeyboard.visible ? "go-down-symbolic" : "mobile-close-app"
        // mobile-close-app (from plasma-frameworks) seems to have less margins than icons from breeze-icons
        iconSizeFactor: MobileShell.KWinVirtualKeyboard.visible ? 1 : 0.75
        
        onTriggered: {
            if (MobileShell.KWinVirtualKeyboard.active) {
                // close keyboard if it is open
                MobileShell.KWinVirtualKeyboard.active = false;
            } else if (taskSwitcher.visible) { 
                // if task switcher is open, close the current window shown
                let indexToClose = root.taskSwitcher.tasksModel.index(root.taskSwitcher.currentTaskIndex, 0);
                root.taskSwitcher.tasksModel.requestClose(indexToClose);
                
            } else if (plasmoid.nativeInterface.hasCloseableActiveWindow) {
                // if task switcher is closed, but there is an active window
                if (root.taskSwitcher.tasksModel.activeTask !== 0) {
                    root.taskSwitcher.tasksModel.requestClose(root.taskSwitcher.tasksModel.activeTask);
                }
            }
        }
    }
}
