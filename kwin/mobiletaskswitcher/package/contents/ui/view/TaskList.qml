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

    // Draws a task at a previous place on the screen, and animates it to where it is laid out now
    component MorphTransition: TaskSwitcherPlugin.RectTransition {
        id: transition

        // animate the item from the rectangle (in scene coordinates, see contentRect()) to where it is now
        function animateFrom(item: Item, rect: rect): void {
            animation.stop();
            progress = 0;
            if (rect.width <= 0) {
                return;
            }
            setTarget(item, rect);
            animation.restart();
        }

        function stop(): void {
            animation.stop();
            progress = 0;
        }

        readonly property NumberAnimation animation: NumberAnimation {
            target: transition
            property: "progress"
            from: 1
            to: 0
            duration: Kirigami.Units.veryLongDuration * 1.25
            easing.type: Easing.OutCubic
        }
    }

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

    // how the whole grid moves while opening and closing
    readonly property GridMotion gridMotion: GridMotion {
        active: root.geometry.isGridLayout
        taskList: root
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

    // ~~ morphing ~~
    // Animates the tasks to their new place when the layout changes, instead of jumping there.
    // Call beginMorph() before the change, and endMorph() with its result after it.

    // Remember where the tasks are on the screen, the result is passed to endMorph().
    function beginMorph(animated = true): var {
        if (!animated) {
            return null;
        }
        const rects = new Map();
        for (const task of tasks()) {
            rects.set(task, task.morphTransition.contentRect(task));
        }
        return rects;
    }

    // animate the tasks from the places remembered by beginMorph()
    function endMorph(rects: var): void {
        for (const task of tasks()) {
            const rect = rects?.get(task);
            if (rect) {
                task.morphTransition.animateFrom(task, rect);
            } else {
                task.morphTransition.stop();
            }
        }
    }

    // run change(), which changes the layout
    function morph(animated: bool, change: var): void {
        const rects = beginMorph(animated);
        change();
        endMorph(rects);
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

    transform: [
        Translate {
            x: root.gridMotion.xOffset / Math.max(0.01, root.navigator.scale)
            y: root.gridMotion.yOffset
        },
        Scale {
            origin.x: root.width / 2
            origin.y: root.height / 2
            xScale: root.navigator.scale
            yScale: root.navigator.scale
        }
    ]

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
            readonly property bool launching: root.controller.launchingTask === currentIndex

            taskSwitcher: root.taskSwitcher

            width: root.geometry.taskWidth
            height: root.geometry.taskHeight

            // ~~ position ~~

            // where this task is placed in the layout
            readonly property TaskSwitcherPlugin.TaskPlacement placement: TaskSwitcherPlugin.TaskPlacement {
                layout: root.geometry.layout
                index: task.currentIndex
            }

            // how the task moves in the carousel while opening and closing
            readonly property CarouselTaskMotion motion: CarouselTaskMotion {
                active: !root.geometry.isGridLayout
                taskList: root
                taskIndex: task.currentIndex
                placement: task.placement
                taskX: task.x
            }

            // the place in the layout, with the motion on top of it
            x: placement.x + repeater.leftMargin - root.geometry.layout.displayedScrollPosition + motion.xOffset
            y: root.taskY + placement.rowOffset + motion.yOffset
            scale: motion.scale
            darken: motion.darken

            // ~~ transitions ~~

            // when launching a task in the grid, it grows from its place to the window, without the rest of the grid moving
            readonly property TaskSwitcherPlugin.RectTransition launchTransition: TaskSwitcherPlugin.RectTransition {
                anchorY: root.geometry.taskHeaderHeight
                progress: task.launching ? root.controller.launchProgress : 0
            }
            // when the layout changes, it is drawn at its old place on the screen and animates to the new one
            readonly property MorphTransition morphTransition: MorphTransition {
                anchorY: root.geometry.taskHeaderHeight
            }
            transform: [launchTransition, morphTransition]

            // ~~ appearance ~~

            // the current task is above the others, then a task being swiped away, and the launched task above all
            z: launching ? 3 : (dragOffset > 0 ? 2 : (isCurrentTask ? 1 : 0))

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
