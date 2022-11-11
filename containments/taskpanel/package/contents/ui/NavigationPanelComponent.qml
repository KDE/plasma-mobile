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
import org.kde.plasma.workspace.keyboardlayout 1.0 as Keyboards

import org.kde.plasma.private.mobileshell 1.0 as MobileShell
import org.kde.plasma.private.mobileshell.state 1.0 as MobileShellState

MobileShell.NavigationPanel {
    id: root
    required property bool opaqueBar
    
    // background is:
    // - opaque if an app is shown or vkbd is shown
    // - translucent if the task switcher is open
    // - transparent if on the homescreen
    backgroundColor: {
        if (root.taskSwitcher.visible) {
            return Qt.rgba(0, 0, 0, 0.1);
        } else {
            return (Keyboards.KWinVirtualKeyboard.visible || opaqueBar) ? PlasmaCore.ColorScope.backgroundColor : "transparent";
        }
    }
    foregroundColorGroup: (!root.taskSwitcher.visible && opaqueBar) ? PlasmaCore.Theme.NormalColorGroup : PlasmaCore.Theme.ComplementaryColorGroup
    shadow: !opaqueBar
        
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
            MobileShell.WindowUtil.showDesktop = false;
            
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
            MobileShellState.HomeScreenControls.openHomeScreen();
            MobileShell.WindowUtil.allWindowsMinimizedChanged();
        }
    }
    
    // close app/keyboard button
    rightAction: MobileShell.NavigationPanelAction {
        id: closeAppAction
        
        enabled: Keyboards.KWinVirtualKeyboard.visible || root.taskSwitcher.visible || MobileShell.WindowUtil.hasCloseableActiveWindow || MobileShell.ShellUtil.isLaunchingApp
        iconSource: Keyboards.KWinVirtualKeyboard.visible ? "go-down-symbolic" : "mobile-close-app"
        // mobile-close-app (from plasma-frameworks) seems to have less margins than icons from breeze-icons
        iconSizeFactor: Keyboards.KWinVirtualKeyboard.visible ? 1 : 0.75
        
        onTriggered: {
            if (Keyboards.KWinVirtualKeyboard.active) {
                // close keyboard if it is open
                Keyboards.KWinVirtualKeyboard.active = false;
            } else if (taskSwitcher.visible) { 
                // if task switcher is open, close the current window shown
                let indexToClose = root.taskSwitcher.tasksModel.index(root.taskSwitcher.currentTaskIndex, 0);
                root.taskSwitcher.tasksModel.requestClose(indexToClose);
                
            } else if (MobileShell.WindowUtil.hasCloseableActiveWindow) {
                // if task switcher is closed, but there is an active window
                if (root.taskSwitcher.tasksModel.activeTask !== 0) {
                    root.taskSwitcher.tasksModel.requestClose(root.taskSwitcher.tasksModel.activeTask);
                }
                MobileShellState.Shell.closeAppLaunchAnimation();
            } else if (MobileShell.ShellUtil.isLaunchingApp) {
                
                // cancel the launching of the app
                MobileShellState.Shell.closeAppLaunchAnimation();
                MobileShell.ShellUtil.cancelLaunchingApp();
            }
        }
    }
    
    rightCornerAction: MobileShell.NavigationPanelAction {
        id: keyboardToggleAction
        visible: Keyboards.KWinVirtualKeyboard.available && !Keyboards.KWinVirtualKeyboard.activeClientSupportsTextInput
        enabled: true
        iconSource: "input-keyboard-virtual-symbolic"
        iconSizeFactor: 0.75
        
        onTriggered: {
            if (Keyboards.KWinVirtualKeyboard.visible) {
                Keyboards.KWinVirtualKeyboard.active = false;
            } else {
                Keyboards.KWinVirtualKeyboard.forceActivate();
            }
        }
    }
}
