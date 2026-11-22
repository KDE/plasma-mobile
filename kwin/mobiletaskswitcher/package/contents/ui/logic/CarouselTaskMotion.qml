// SPDX-FileCopyrightText: 2024 Micah Stanley <stanleymicah@proton.me>
// SPDX-FileCopyrightText: 2024-2025 Luis Büchi <luis.buechi@kdemail.net>
// SPDX-License-Identifier: GPL-2.0-or-later

pragma ComponentBehavior: Bound

import QtQuick

import org.kde.plasma.private.mobileshell.taskswitcherplugin as TaskSwitcherPlugin
import "../view"

/**
 * Logic for positioning a task in a "carousel" (row) layout
 */
QtObject {
    id: root

    required property TaskList taskList
    required property TaskSwitcherPlugin.TaskPlacement placement
    required property int taskIndex
    required property real taskX

    readonly property TaskSwitcherGeometry geometry: taskList.geometry
    readonly property TaskSwitcherController controller: taskList.controller
    readonly property TaskSwitcherPlugin.TaskNavigator navigator: controller.navigator
    readonly property TaskSwitcherPlugin.TaskSwitcherGesture gesture: controller.gesture
    readonly property TaskSwitcherPlugin.TaskPlacement currentPlacement: taskList.currentTaskPlacement
    readonly property TaskDrawerOffset drawerOffset: controller.drawerOffset

    readonly property bool isCurrentTask: taskIndex == navigator.displayedTaskIndex

    // The current task stays in place when the gesture started in it, or in the opened task drawer
    readonly property bool staysInPlace: isCurrentTask && !navigator.onHomeScreen

    readonly property real xOffset: resistanceXOffset - slideInXOffset
    readonly property real yOffset: {
        if (navigator.startedInApp || controller.taskDrawerOpened) {
            return taskList.taskSwitcher.height / 4 * resistanceFactor;
        }
        // from the home screen: the tasks also move down while sliding in
        return taskList.taskY / (controller.openedWithButton ? 1 : slideOutScale) - taskList.taskY;
    }

    readonly property real scale: (staysInPlace || controller.openedWithButton) ? 1 : (1 + resistanceFactor) * slideOutScale

    // darken the task as it gets away from the center of the screen
    readonly property real darken: {
        const centeredX = (taskList.width - geometry.taskWidth) / 2;
        // in task widths, while opening and closing relative to where the current task is placed
        const distanceFromCenter = Math.abs(taskX - centeredX - (controller.opening || controller.state.closing ? currentPlacement.scrollPosition - navigator.xPosition : 0)) / geometry.taskWidth;
        // starts darkening a fifth of a task width away, up to 0.05
        return Math.max(0, Math.min(0.25, distanceFromCenter) - 0.2);
    }

    // ~~ sliding in from the sides ~~

    // the tasks are a bit larger while slid out, and move down from the home screen
    readonly property real slideOutScale: 1 + slideOutProgress * 0.075

    // how far the task is slid out of view, following the task drawer offset with an animation:
    // 0 in place, see TaskDrawerOffset for the other values (always 0 for the current task in the opened task drawer)
    property real slideOutProgress: drawerOffset.value * ((controller.taskDrawerOpened && isCurrentTask) ? 0 : 1)
    Behavior on slideOutProgress {
        NumberAnimation {
            duration: root.slideInSide < 0 ? root.drawerOffset.durationRight : root.drawerOffset.durationLeft
            easing.type: root.drawerOffset.easing
            easing.overshoot: 0.85
        }
    }

    // the side the task slides in from: the tasks after the current one (older) from the left (1),
    // the ones before it from the right (-1)
    readonly property real slideInSide: navigator.displayedTaskIndex > taskIndex ? -1 : 1

    // whether the task slides in from the side: all except the one staying in place, and none when scrubbing from an app
    readonly property bool slidesIn: !staysInPlace && !(controller.isInTaskScrubMode && navigator.startedInApp && !controller.taskDrawerOpened)

    // when the gesture started in an app or the opened task drawer, the tasks follow the finger sideways
    readonly property bool followsFingerSideways: !navigator.onHomeScreen && drawerOffset.homeTouchPositionX == 0

    // how far the task travels to get out of view: half the screen, plus how far the finger moved the list sideways
    readonly property real distanceOutOfView: {
        let distance = geometry.windowWidth / 2 + (followsFingerSideways ? gesture.touchX * slideInSide : 0);
        if (!navigator.onHomeScreen) {
            distance += Math.abs(currentPlacement.scrollPosition - (navigator.xPosition + gesture.touchX / navigator.scale));
        }
        return distance;
    }

    // from the home screen, the task drawer follows the finger sideways while it is out of view or peeking
    readonly property real homeFingerOffset: {
        const peekToHiddenProgress = (slideOutProgress - drawerOffset.peekValue) / (drawerOffset.homeValue - drawerOffset.peekValue);
        return drawerOffset.homeTouchPositionX * (1 - Math.max(0, Math.min(1, peekToHiddenProgress)));
    }

    // the x offset of sliding in
    readonly property real slideInXOffset: slidesIn ? (distanceOutOfView / navigator.scale - homeFingerOffset) * slideOutProgress * slideInSide : 0

    // ~~ resistance ~~
    // the tasks other than the current one are larger and move more slowly, while the list is larger than in the opened task drawer

    // how much larger the task is, and how much more slowly it moves: 0 at the opened scale, growing as the list grows
    readonly property real resistanceFactor: (staysInPlace || controller.openedWithButton) ? 0 : 1 - Math.min(navigator.scale, 1)

    // compensate for the larger size of the tasks around them, and move more slowly
    readonly property real resistanceXOffset: geometry.taskWidth * (scale - 1)
        * ((navigator.onHomeScreen ? 1.0 : 0.25) * slideInSide - (placement.column - currentPlacement.column))
}
