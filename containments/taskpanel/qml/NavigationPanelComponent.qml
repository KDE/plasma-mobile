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
import org.kde.plasma.private.mobileshell.shellsettingsplugin as ShellSettings
import org.kde.plasma.private.mobileshell.rotationplugin as RotationPlugin

import org.kde.kirigami as Kirigami

MobileShell.NavigationPanel {
    id: root
    required property bool opaqueBar

    // background is:
    // - opaque if an app is shown or vkbd is shown
    // - translucent if the task switcher is open
    // - transparent if on the homescreen
    backgroundColor: opaqueBar ? Kirigami.Theme.backgroundColor : "transparent"
    foregroundColorGroup: opaqueBar ? Kirigami.Theme.Window : Kirigami.Theme.Complementary
    shadow: !opaqueBar

    MobileShellState.PanelSettingsDBusClient {
        id: panelSettings
        screenName: Screen.name
    }

    leftPadding: panelSettings.navigationPanelLeftPadding
    rightPadding: panelSettings.navigationPanelRightPadding

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
        filterNotMaximized: false
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
        shrinkSize: 4

        onTriggered: {
            Plasmoid.triggerTaskSwitcher();
        }
    }

    // home button
    middleAction: MobileShell.NavigationPanelAction {
        id: homeAction

        enabled: true
        iconSource: "start-here-kde"

        onTriggered: {
            MobileShellState.ShellDBusClient.openHomeScreen();
        }
    }

    // close app/keyboard button
    rightAction: MobileShell.NavigationPanelAction {
        id: closeAppAction

        enabled: Keyboards.KWinVirtualKeyboard.visible || WindowPlugin.WindowUtil.hasCloseableActiveWindow
        iconSource: Keyboards.KWinVirtualKeyboard.visible ? "go-down-symbolic" : "mobile-close-app"
        // mobile-close-app (from plasma-frameworks) seems to have fewer margins than icons from breeze-icons
        shrinkSize: Keyboards.KWinVirtualKeyboard.visible ? 0 : 4

        onTriggered: {
            if (Keyboards.KWinVirtualKeyboard.visible) {
                // close keyboard if it is open
                Keyboards.KWinVirtualKeyboard.active = false;
            } else if (WindowPlugin.WindowUtil.hasCloseableActiveWindow) {
                // if task switcher is closed, but there is an active window
                if (tasksModel.activeTask !== 0) {
                    tasksModel.requestClose(tasksModel.activeTask);
                }
            }
        }
    }

    leftCornerAction: MobileShell.NavigationPanelAction {
        id: rotationAction
        visible: RotationPlugin.RotationUtil.showRotationButton
        enabled: true
        iconSource: "rotation-allowed-symbolic"
        shrinkSize: 4

        onTriggered: {
            RotationPlugin.RotationUtil.rotateToSuggestedRotation();
        }
    }

    rightCornerAction: MobileShell.NavigationPanelAction {
        id: keyboardToggleAction
        visible: ShellSettings.Settings.alwaysShowKeyboardToggleOnNavigationPanel ||
                 (Keyboards.KWinVirtualKeyboard.available && !Keyboards.KWinVirtualKeyboard.activeClientSupportsTextInput)
        enabled: true
        iconSource: "input-keyboard-virtual-symbolic"
        shrinkSize: 4

        onTriggered: {
            if (Keyboards.KWinVirtualKeyboard.active) {
                Keyboards.KWinVirtualKeyboard.active = false;
            } else {
                Keyboards.KWinVirtualKeyboard.forceActivate();
            }
        }
    }
}
