// SPDX-FileCopyrightText: 2021-2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick 2.4
import QtQuick.Layouts 1.1
import QtQuick.Window 2.15

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.workspace.keyboardlayout 1.0 as Keyboards

import org.kde.plasma.private.mobileshell 1.0 as MobileShell
import org.kde.plasma.private.mobileshell.state 1.0 as MobileShellState
import org.kde.taskmanager 0.1 as TaskManager

MobileShell.NavigationPanel {
    id: root
    required property bool opaqueBar
    
    // background is:
    // - opaque if an app is shown or vkbd is shown
    // - translucent if the task switcher is open
    // - transparent if on the homescreen
    backgroundColor: (Keyboards.KWinVirtualKeyboard.visible || opaqueBar) ? PlasmaCore.ColorScope.backgroundColor : "transparent";
    foregroundColorGroup: opaqueBar ? PlasmaCore.Theme.NormalColorGroup : PlasmaCore.Theme.ComplementaryColorGroup
    shadow: !opaqueBar
        
    // do not enable drag gesture when task switcher is already open
    // also don't disable drag gesture mid-drag
    dragGestureEnabled: false // !root.taskSwitcher.visible || root.taskSwitcher.taskSwitcherState.currentlyBeingOpened
    
    TaskManager.VirtualDesktopInfo {
        id: virtualDesktopInfo
    }

    TaskManager.ActivityInfo {
        id: activityInfo
    }

    TaskManager.TasksModel {
        id: tasksModel
        filterByVirtualDesktop: true
        filterByActivity: true
        filterNotMaximized: true
        filterByScreen: true
        filterHidden: true

        virtualDesktop: virtualDesktopInfo.currentDesktop
        activity: activityInfo.currentActivity

        groupMode: TaskManager.TasksModel.GroupDisabled
    }

    // ~~~~
    // navigation panel actions
    
    // toggle task switcher button
    leftAction: MobileShell.NavigationPanelAction {
        id: taskSwitcherAction
        
        enabled: true
        iconSource: "mobile-task-switcher"
        iconSizeFactor: 0.75
        
        onTriggered: {
            plasmoid.nativeInterface.triggerTaskSwitcher();
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
        
        enabled: Keyboards.KWinVirtualKeyboard.visible || MobileShell.WindowUtil.hasCloseableActiveWindow
        iconSource: Keyboards.KWinVirtualKeyboard.visible ? "go-down-symbolic" : "mobile-close-app"
        // mobile-close-app (from plasma-frameworks) seems to have less margins than icons from breeze-icons
        iconSizeFactor: Keyboards.KWinVirtualKeyboard.visible ? 1 : 0.75
        
        onTriggered: {
            if (Keyboards.KWinVirtualKeyboard.active) {
                // close keyboard if it is open
                Keyboards.KWinVirtualKeyboard.active = false;
            } else if (MobileShell.WindowUtil.hasCloseableActiveWindow) {
                // if task switcher is closed, but there is an active window
                if (tasksModel.activeTask !== 0) {
                    tasksModel.requestClose(tasksModel.activeTask);
                }
                MobileShellState.Shell.closeAppLaunchAnimation();
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
