// SPDX-FileCopyrightText: 2021-2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Window

import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.workspace.keyboardlayout as Keyboards

import org.kde.plasma.private.mobileshell as MobileShell
import org.kde.plasma.private.mobileshell.state as MobileShellState
import org.kde.taskmanager as TaskManager
import org.kde.plasma.private.mobileshell.windowplugin as WindowPlugin

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
            Plasmoid.triggerTaskSwitcher();
        }
    }
    
    // home button
    middleAction: MobileShell.NavigationPanelAction {
        id: homeAction
        
        enabled: true
        iconSource: "start-here-kde"
        iconSizeFactor: 1
        
        onTriggered: {
            MobileShellState.ShellDBusClient.openHomeScreen();
        }
    }
    
    // close app/keyboard button
    rightAction: MobileShell.NavigationPanelAction {
        id: closeAppAction
        
        enabled: Keyboards.KWinVirtualKeyboard.visible || WindowPlugin.WindowUtil.hasCloseableActiveWindow
        iconSource: Keyboards.KWinVirtualKeyboard.visible ? "go-down-symbolic" : "mobile-close-app"
        // mobile-close-app (from plasma-frameworks) seems to have less margins than icons from breeze-icons
        iconSizeFactor: Keyboards.KWinVirtualKeyboard.visible ? 1 : 0.75
        
        onTriggered: {
            if (Keyboards.KWinVirtualKeyboard.active) {
                // close keyboard if it is open
                Keyboards.KWinVirtualKeyboard.active = false;
            } else if (WindowPlugin.WindowUtil.hasCloseableActiveWindow) {
                // if task switcher is closed, but there is an active window
                if (tasksModel.activeTask !== 0) {
                    tasksModel.requestClose(tasksModel.activeTask);
                }
                MobileShellState.ShellDBusClient.closeAppLaunchAnimation();
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
