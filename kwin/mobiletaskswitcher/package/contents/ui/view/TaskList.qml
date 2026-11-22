// SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
// SPDX-FileCopyrightText: 2025 Luis Büchi <luis.buechi@kdemail.net>
// SPDX-License-Identifier: GPL-2.0-or-later

pragma ComponentBehavior: Bound

import QtQuick

import org.kde.kirigami as Kirigami

import org.kde.plasma.private.mobileshell.taskswitcherplugin as TaskSwitcherPlugin
import "../logic"

/**
 * The tasks, placed by the current layout, with the motion of the task switcher opening and closing on top.
 */
MouseArea {
    id: root

    required property TaskSwitcher taskSwitcher
    readonly property TaskSwitcherPlugin.MobileTaskSwitcherState taskSwitcherState: taskSwitcher.state
    readonly property TaskSwitcherGeometry geometry: taskSwitcher.geometry
    readonly property TaskSwitcherController controller: taskSwitcher.controller
    readonly property TaskSwitcherPlugin.TaskNavigator navigator: controller.navigator

    readonly property int count: repeater.count

    // number of tasks being dragged, to know whether a task is being swiped up
    property int taskInteractingCount: 0

    // the y position of the tasks: tracking the finger when dragged further up than the opened position,
    // and moved up in scrub mode to make space for the scrub icons
    readonly property real taskY: {
        let y = geometry.restingTaskY;
        if (navigator.overDragged && (navigator.startedInApp || controller.taskDrawerOpened)) {
            y -= navigator.overDragOffset;
        }
        if (controller.isInTaskScrubMode && !taskSwitcherState.closing) {
            y -= geometry.scrubModeOverrun;
        }
        return Math.round(y);
    }

    // where the current task is placed in the layout
    readonly property TaskSwitcherPlugin.TaskPlacement currentTaskPlacement: TaskSwitcherPlugin.TaskPlacement {
        layout: root.geometry.layout
        index: root.navigator.displayedTaskIndex
    }

    function getTaskAt(index: int): Task {
        return repeater.itemAt(index);
    }

    function tasks(): list<Task> {
        let tasks = [];
        for (let i = 0; i < repeater.count; i++) {
            const task = repeater.itemAt(i);
            if (task) {
                tasks.push(task);
            }
        }
        return tasks;
    }

    function closeAll(): void {
        for (const task of tasks()) {
            task.closeApp();
        }
    }

    function minimizeAll(): void {
        for (const task of tasks()) {
            if (!task.window.minimized) {
                task.minimizeApp();
            }
        }
    }

    transform: Scale {
        origin.x: root.width / 2
        origin.y: root.height / 2
        xScale: root.navigator.scale
        yScale: root.navigator.scale
    }

    // tapping on the background goes home
    onClicked: controller.hide()

    onPressedChanged: {
        // stop the animations when touched, unless opening or closing
        if (pressed && !controller.opening && !taskSwitcherState.closing) {
            controller.cancelAnimations();
        }
    }

    Repeater {
        id: repeater
        model: root.taskSwitcher.tasksModel

        // left margin from root edge such that the task is centered
        readonly property real leftMargin: (root.width / 2) - (root.geometry.taskWidth / 2)

        delegate: Task {
            id: task

            readonly property bool isCurrentTask: currentIndex == root.navigator.displayedTaskIndex

            taskSwitcher: root.taskSwitcher

            width: root.geometry.taskWidth
            height: root.geometry.taskHeight

            // ~~ position ~~

            // where this task is placed in the layout
            readonly property TaskSwitcherPlugin.TaskPlacement placement: TaskSwitcherPlugin.TaskPlacement {
                layout: root.geometry.layout
                index: task.currentIndex
            }

            // the x position in the list, animated when the tasks before it are closed in the opened task drawer
            // (not when the task switcher is set up)
            property real listX: placement.x
            Behavior on listX {
                enabled: root.controller.taskDrawerOpened
                NumberAnimation {
                    duration: Kirigami.Units.longDuration
                    easing.type: Easing.InOutQuad
                }
            }

            // how the task moves in the carousel while opening and closing
            readonly property CarouselTaskMotion motion: CarouselTaskMotion {
                taskList: root
                taskIndex: task.currentIndex
                placement: task.placement
                taskX: task.x
            }

            // the place in the layout, with the motion on top of it
            x: listX + repeater.leftMargin - root.geometry.layout.displayedScrollPosition + motion.xOffset
            y: root.taskY + placement.rowOffset + motion.yOffset
            scale: motion.scale
            darken: motion.darken

            // ~~ appearance ~~

            // the current task is above the others
            z: isCurrentTask ? 1 : 0

            // only show header once task switcher is opened
            showHeader: !root.taskSwitcherState.gestureInProgress && !root.taskSwitcherState.closing && !root.controller.isInTaskScrubMode

            // fade out as the task switcher closes
            opacity: root.controller.closingFactor

            onInteractingActiveChanged: {
                root.taskInteractingCount = Math.max(0, root.taskInteractingCount + (interactingActive ? 1 : -1));
            }
        }
    }
}
