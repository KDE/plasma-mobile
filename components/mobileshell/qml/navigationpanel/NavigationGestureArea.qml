/*
 *  SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
 *  SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.4
import QtQuick.Layouts 1.1
import QtQuick.Window 2.2
import Qt5Compat.GraphicalEffects

import org.kde.taskmanager 0.1 as TaskManager
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kquickcontrolsaddons 2.0

import org.kde.plasma.private.nanoshell 2.0 as NanoShell
import org.kde.plasma.private.mobileshell 1.0 as MobileShell

Item {
    id: root

    property var taskSwitcher

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        
        // drag gesture
        property int oldMouseY: 0
        property int startMouseY: 0
        property int oldMouseX: 0
        property int startMouseX: 0
        property bool opening: false

        enabled: !taskSwitcher.visible
        
        onPressed: {
            startMouseX = oldMouseX = mouse.x;
            startMouseY = oldMouseY = mouse.y;
        }

        onPositionChanged: {
            if (root.taskSwitcher.visible || taskSwitcher.taskSwitcherState.currentlyBeingOpened) {
                // update task switcher drag
                let offsetY = (mouse.y - oldMouseY) * 0.5; // we want to make the gesture take a longer swipe than it being pixel perfect
                let offsetX = (mouse.x - oldMouseX) * 0.7; // we want to make the gesture not too hard to swipe, but not too easy
                taskSwitcher.taskSwitcherState.yPosition = Math.max(0, taskSwitcher.taskSwitcherState.yPosition - offsetY);
                taskSwitcher.taskSwitcherState.xPosition = taskSwitcher.taskSwitcherState.xPosition - offsetX;
            }

            if (!root.taskSwitcher.visible && Math.abs(startMouseX - mouse.x) > PlasmaCore.Units.gridUnit && taskSwitcher.tasksCount && taskSwitcher.tasksModel.activeTask.row >= 0){
                // start switch task gesture
                taskSwitcher.taskSwitcherState.scrollingTasks = true;
                root.taskSwitcher.show(false);
            } else if (!root.taskSwitcher.visible && Math.abs(startMouseY - mouse.y) > PlasmaCore.Units.gridUnit && taskSwitcher.tasksCount) {
                // start task switcher opening gesture
                root.taskSwitcher.show(false);
            }

            oldMouseY = mouse.y;
            oldMouseX = mouse.x;
        }

        onReleased: {
            if (taskSwitcher.taskSwitcherState.currentlyBeingOpened) {
                taskSwitcher.taskSwitcherState.updateState();
            }
        }
    }
}

