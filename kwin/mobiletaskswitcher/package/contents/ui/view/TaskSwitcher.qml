// SPDX-FileCopyrightText: 2015 Marco Martin <notmart@gmail.com>
// SPDX-FileCopyrightText: 2021-2024 Devin Lin <devin@kde.org>
// SPDX-FileCopyrightText: 2024-2025 Luis Büchi <luis.buechi@kdemail.net>
// SPDX-License-Identifier: GPL-2.0-or-later

pragma ComponentBehavior: Bound

import QtQuick

import org.kde.kirigami as Kirigami
import org.kde.plasma.private.mobileshell as MobileShell
import org.kde.plasma.private.mobileshell.shellsettingsplugin as ShellSettings
import org.kde.plasma.private.mobileshell.taskswitcherplugin as TaskSwitcherPlugin

import org.kde.kwin 3.0 as KWinComponents
import org.kde.kwin.private.effects 1.0
import "../logic"

/**
 * Component that provides a task switcher.
 */
FocusScope {
    id: root
    focus: true

    property TaskSwitcherPlugin.MobileTaskSwitcherState state
    readonly property QtObject targetScreen: KWinComponents.SceneView.screen

    readonly property real navBottomMargin: MobileShell.Constants.navigationPanelOnSide(width, height) ? 0 : MobileShell.Constants.navigationPanelThickness
    readonly property real navRightMargin: MobileShell.Constants.navigationPanelOnSide(width, height) ? MobileShell.Constants.navigationPanelThickness : 0
    readonly property real topMargin: ShellSettings.Settings.autoHidePanelsEnabled ? 0 : MobileShell.Constants.topPanelHeight
    readonly property real bottomMargin: ShellSettings.Settings.autoHidePanelsEnabled ? 0 : navBottomMargin
    readonly property real leftMargin: 0
    readonly property real rightMargin: ShellSettings.Settings.autoHidePanelsEnabled ? 0 : navRightMargin

    readonly property TaskSwitcherGeometry geometry: TaskSwitcherGeometry {
        taskSwitcher: root
    }

    readonly property TaskSwitcherController controller: TaskSwitcherController {
        taskSwitcher: root
        geometry: root.geometry
        taskList: taskList
        flickable: flickable
    }

    readonly property TaskSwitcherPlugin.TaskFilterModel tasksModel: TaskSwitcherPlugin.TaskFilterModel {
        screenName: root.targetScreen.name
        windowModel: root.state.taskModel
    }

    readonly property int tasksCount: taskList.count

    Keys.onEscapePressed: controller.hide()

    // called by c++ plugin
    function hideAnimation(): void {
        fadeOutAnim.restart();
    }

    // reset what is left over from the last time the task switcher was shown
    function resetView(): void {
        fadeOutAnim.stop();
        container.opacity = 1;
        closeAllButton.closeRequested = false;
    }

    function vibrate(): void {
        haptics.buttonVibrate();
    }

    MobileShell.HapticsEffect {
        id: haptics
    }

    // view of the desktop background
    KWinComponents.DesktopBackground {
        id: backgroundItem
        activity: KWinComponents.Workspace.currentActivity
        desktop: KWinComponents.Workspace.currentDesktop
        outputName: root.targetScreen.name
    }

    // background colour
    Rectangle {
        id: backgroundRect
        anchors.fill: root

        opacity: container.opacity
        color: Qt.rgba(0, 0, 0, 0.6 * root.controller.closingFactor * root.backgroundColorOpacity)
    }

    // animate the background opacity based off of the state.
    property real backgroundColorOpacity: 1
    Behavior on backgroundColorOpacity {
        id: backgroundColorOpacityAn
        NumberAnimation {
            duration: Kirigami.Units.longDuration
        }
    }

    function setBackgroundColorOpacity(opacity: real, animated: bool): void {
        backgroundColorOpacityAn.enabled = animated;
        backgroundColorOpacity = opacity;
        backgroundColorOpacityAn.enabled = true;
    }

    TaskSwitcherPanel {
        id: panelLoader
        z: !root.state.closing ? 1 : 0
        taskSwitcher: root

        onTaskSwitcherRequested: root.controller.activateCurrentTask()
        onHomeRequested: root.controller.hide()
        onCloseCurrentTaskRequested: taskList.getTaskAt(root.controller.navigator.currentTaskIndex).closeApp()
    }

    // task list
    Item {
        id: container

        // provide shell margins
        anchors.fill: root
        anchors.leftMargin: root.leftMargin
        anchors.rightMargin: root.rightMargin
        anchors.bottomMargin: root.bottomMargin
        anchors.topMargin: root.topMargin

        NumberAnimation on opacity {
            id: fadeOutAnim
            running: false
            to: 0
            duration: Kirigami.Units.longDuration
            easing.type: Easing.InOutQuad

            onFinished: {
                closeAllButton.closeRequested = false;
            }
        }

        EmptyPlaceholder {
            anchors.centerIn: container
            taskSwitcher: root
        }

        ScrubOverlay {
            anchors.fill: container
            taskSwitcher: root
        }

        // flicking area for task switcher
        FlickContainer {
            id: flickable
            anchors.fill: container

            taskSwitcher: root

            // don't allow FlickContainer to steal from swiping on tasks
            interactive: taskList.taskInteractingCount === 0

            // the item is effectively anchored to the flickable bounds
            TaskList {
                id: taskList
                taskSwitcher: root

                x: flickable.contentX
                width: flickable.width
                height: flickable.height
            }

            CloseAllButton {
                id: closeAllButton
                taskSwitcher: root
                taskList: taskList

                anchors {
                    bottom: taskList.bottom
                    bottomMargin: (root.geometry.restingTaskY - root.geometry.layout.rowsOverhang) * 0.75
                    horizontalCenter: taskList.horizontalCenter
                }
            }
        }
    }
}
