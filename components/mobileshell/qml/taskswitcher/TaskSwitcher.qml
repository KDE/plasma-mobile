/*
 *   SPDX-FileCopyrightText: 2015 Marco Martin <notmart@gmail.com>
 *   SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 *
 *   SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.1

import org.kde.taskmanager 0.1 as TaskManager
import org.kde.plasma.core 2.1 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.private.nanoshell 2.0 as NanoShell
import org.kde.plasma.private.mobileshell 1.0 as MobileShell

import "../components" as Components

Item {
    id: root
    visible: false
    opacity: 0
    
    // state object
    property var taskSwitcherState: TaskSwitcherState {
        taskSwitcher: root
    }
    
    // task list model
    property TaskManager.TasksModel model
    readonly property int tasksCount: model.count

    property var displaysModel: MobileShell.DisplaysModel {}
    
    onVisibleChanged: MobileShell.HomeScreenControls.taskSwitcherVisible = visible;
    
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

    // TODO close task switcher when an app opens while it is open, otherwise the navbar becomes glitched
    // TODO filter shell windows
    
//BEGIN functions

    function show(animation) {
        // reset values
        taskSwitcherState.cancelAnimations();
        taskSwitcherState.yPosition = 0;
        taskSwitcherState.xPosition = 0;
        taskSwitcherState.wasInActiveTask = root.model.activeTask.row >= 0;
        taskSwitcherState.currentlyBeingOpened = true;
        
        // skip to first active task
        if (taskSwitcherState.wasInActiveTask) {
            taskSwitcherState.goToTaskIndex(root.model.activeTask.row);
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

        var newActiveIdx = root.model.index(id, 0)
        var newActiveGeo = tasksModel.data(newActiveIdx, TaskManager.AbstractTasksModel.ScreenGeometry)
        for (var i = 0 ; i < tasksModel.count; i++) {
            var idx = root.model.index(i, 0)
            if (i == id) {
                root.model.requestActivate(idx);
            } else if (!tasksModel.data(idx, TaskManager.AbstractTasksModel.IsMinimized)) {
                var geo = tasksModel.data(idx, TaskManager.AbstractTasksModel.ScreenGeometry)
                // only minimize the other windows in the same screen
                if (geo === newActiveGeo) {
                    tasksModel.requestToggleMinimized(idx);
                }
            }
        }
        
        instantHide();
    }
    
    function minimizeAll() {
        for (var i = 0 ; i < tasksModel.count; i++) {
            var idx = tasksModel.makeModelIndex(i);
            if (!tasksModel.data(idx, TaskManager.AbstractTasksModel.IsMinimized)) {
                tasksModel.requestToggleMinimized(idx);
            }
        }
    }

//END functions

    NumberAnimation on opacity {
        id: closeAnim
        to: 0
        duration: PlasmaCore.Units.shortDuration
        easing.type: Easing.InOutQuad
        onFinished: {
            root.visible = false;
        }
    }

    // background colour
    Rectangle {
        id: backgroundRect
        anchors.fill: parent
        
        color: {
            // animate background colour only if opening from the homescreen
            if (taskSwitcherState.wasInActiveTask) {
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
        anchors.rightMargin: MobileShell.TaskPanelControls.isPortrait ? 0 : MobileShell.TaskPanelControls.panelWidth
        anchors.bottomMargin: MobileShell.TaskPanelControls.isPortrait ? MobileShell.TaskPanelControls.panelHeight : 0
        anchors.topMargin: MobileShell.TopPanelControls.panelHeight
        
        FlickContainer {
            id: flickable
            anchors.fill: parent
            taskSwitcherState: root.taskSwitcherState
            
            // the item is effectively anchored to the flickable bounds
            TaskList {
                taskSwitcher: root
                x: flickable.contentX
                width: flickable.width
                height: flickable.height
            }
        }
    }
}
