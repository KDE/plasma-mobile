/*
 *   SPDX-FileCopyrightText: 2015 Marco Martin <notmart@gmail.com>
 *   SPDX-FileCopyrightText: 2021-2022 Devin Lin <devin@kde.org>
 *
 *   SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.1
import QtQuick.Window 2.15

import org.kde.taskmanager 0.1 as TaskManager
import org.kde.plasma.core 2.1 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.private.nanoshell 2.0 as NanoShell
import org.kde.plasma.private.mobileshell 1.0 as MobileShell
import org.kde.plasma.private.mobileshell.state 1.0 as MobileShellState

import "../components" as Components

/**
 * Component that provides a task switcher.
 */
Item {
    id: root
    visible: false
    opacity: 0

    /**
     * Margins for the content (taking shell panels into account).
     */
    required property real topMargin
    required property real bottomMargin
    required property real leftMargin
    required property real rightMargin

    // state object
    property var taskSwitcherState: TaskSwitcherState {
        taskSwitcher: root
    }
    
    /**
     * The task manager model to use for the tasks switcher.
     */
    property TaskManager.TasksModel tasksModel
    
    /**
     * The number of tasks in the given task manager model.
     */
    readonly property int tasksCount: tasksModel.count

    /**
     * The screen model to be used for moving windows between screens.
     */
    property var displaysModel: MobileShell.DisplaysModel {}
    
    /**
     * Whether the window is active.
     */
    property bool windowActive: Window.active
    onWindowActiveChanged: {
        // if a window has popped up in front, close the task switcher
        if (visible && !windowActive) {
            hide();
        }
    }
    
    // update API property
    onVisibleChanged: MobileShellState.HomeScreenControls.taskSwitcherVisible = visible;
    
    // keep track of task list events
    property int oldTasksCount: tasksCount
    onTasksCountChanged: {
        if (tasksCount == 0) {
            hide();
        } else if (tasksCount < oldTasksCount && taskSwitcherState.currentTaskIndex >= tasksCount - 1) {
            // if the user is on the last task, and it is closed, scroll left
            taskSwitcherState.animateGoToTaskIndex(tasksCount - 1, PlasmaCore.Units.longDuration);
        }
        
        oldTasksCount = tasksCount;
    }

    Timer {
        id: reorderTimer

        interval: 5000

        onTriggered: tasksModel.taskReorderingEnabled = true
    }

//BEGIN functions

    function show(animation) {
        // reset values
        taskSwitcherState.cancelAnimations();
        taskSwitcherState.yPosition = 0;
        taskSwitcherState.xPosition = 0;
        taskSwitcherState.wasInActiveTask = tasksModel.activeTask.row >= 0;
        taskSwitcherState.currentlyBeingOpened = true;

        reorderTimer.stop();
        tasksModel.taskReorderingEnabled = false;

        // skip to first active task
        if (taskSwitcherState.wasInActiveTask) {
            taskSwitcherState.goToTaskIndex(tasksModel.activeTask.row);
        } else {
            taskSwitcherState.goToTaskIndex(0);
        }
        
        // show task switcher, hide all running apps
        visible = true;
        opacity = 1;
        minimizeAll();
        
        // fully open the panel (if this is a button press, not gesture)
        if (animation) {
            taskSwitcherState.open();
        }
    }
    
    function instantHide() {
        opacity = 0;
        visible = false;
        closeAllButton.closeRequested = false;
    }
    
    function hide() {
        closeAnim.restart();
    }
    
    // scroll to delegate index, and activate it
    function activateWindow(id) {
        taskSwitcherState.openApp(id);
    }
    
    function setSingleActiveWindow(id) {
        if (id < 0) {
            return;
        }

        var newActiveIdx = tasksModel.index(id, 0)
        var newActiveGeo = tasksModel.data(newActiveIdx, TaskManager.AbstractTasksModel.ScreenGeometry)
        for (var i = 0 ; i < tasksModel.count; i++) {
            var idx = tasksModel.index(i, 0)
            if (i == id) {
                tasksModel.requestActivate(idx);
                // ensure the window is in maximized state
                if (!tasksModel.data(idx, TaskManager.AbstractTasksModel.IsMaximized)) {
                    tasksModel.requestToggleMaximized(idx);
                }
            } else if (!tasksModel.data(idx, TaskManager.AbstractTasksModel.IsMinimized)) {
                var geo = tasksModel.data(idx, TaskManager.AbstractTasksModel.ScreenGeometry)
                // only minimize the other windows in the same screen
                if (geo === newActiveGeo) {
                    tasksModel.requestToggleMinimized(idx);
                }
            }
        }
        
        instantHide();

        if (taskSwitcherState.wasInActiveTask) {
            reorderTimer.restart();
        } else {
            tasksModel.taskReorderingEnabled = true;
        }
    }
    
    function minimizeAll() {
        MobileShell.WindowUtil.unsetAllMinimizedGeometries(root);
        MobileShell.WindowUtil.minimizeAll();
    }

//END functions

    NumberAnimation on opacity {
        id: closeAnim
        to: 0
        duration: PlasmaCore.Units.shortDuration
        easing.type: Easing.InOutQuad
                
        onFinished: {
            root.visible = false;
            tasksModel.taskReorderingEnabled = true;
            closeAllButton.closeRequested = false;
        }
    }

    // background colour
    Rectangle {
        id: backgroundRect
        anchors.fill: parent
        
        color: {
            // animate background colour only if we are *not* opening from the homescreen
            if (taskSwitcherState.wasInActiveTask || !taskSwitcherState.currentlyBeingOpened) {
                return Qt.rgba(0, 0, 0, 0.6);
            } else {
                return Qt.rgba(0, 0, 0, 0.6 * Math.min(1, taskSwitcherState.yPosition / taskSwitcherState.openedYPosition));
            }
        }
    }
    
    Item {
        id: container
        
        // provide shell margins
        anchors.fill: parent
        anchors.leftMargin: root.leftMargin
        anchors.rightMargin: root.rightMargin
        anchors.bottomMargin: root.bottomMargin
        anchors.topMargin: root.topMargin
        
        FlickContainer {
            id: flickable
            
            anchors.fill: parent
            
            taskSwitcherState: root.taskSwitcherState
            
            // the item is effectively anchored to the flickable bounds
            TaskList {
                id: taskList
                shellTopMargin: root.topMargin
                shellBottomMargin: root.bottomMargin
                
                taskSwitcher: root
                
                opacity: {
                    // animate opacity only if we are *not* opening from the homescreen
                    if (taskSwitcherState.wasInActiveTask || !taskSwitcherState.currentlyBeingOpened) {
                        return 1;
                    } else {
                        Math.min(1, taskSwitcherState.yPosition / taskSwitcherState.openedYPosition);
                    }
                }
                
                x: flickable.contentX
                width: flickable.width
                height: flickable.height
                
                PlasmaComponents.ToolButton {
                    id: closeAllButton
                    
                    property bool closeRequested: false
                    
                    anchors {
                        bottom: parent.bottom
                        bottomMargin: taskList.taskY / 2
                        horizontalCenter: parent.horizontalCenter
                    }
                    
                    PlasmaCore.ColorScope.colorGroup: PlasmaCore.Theme.ComplementaryColorGroup
                    PlasmaCore.ColorScope.inherit: false
                    
                    opacity: taskSwitcherState.currentlyBeingOpened || taskSwitcherState.currentlyBeingClosed || !root.visible ? 0.0 : 1.0
                    
                    Behavior on opacity {
                        NumberAnimation {
                            duration: PlasmaCore.Units.shortDuration
                        }
                    }
                    
                    icon.name: "edit-clear-history"
                    font.bold: true
                    
                    text: closeRequested ? "Confirm Close All" : "Close All"
                    
                    onClicked: {
                        if (closeRequested) {
                            taskList.closeAll();
                        } else {
                            closeRequested = true;
                        }
                    }
                }
            }
        }
    }
}
