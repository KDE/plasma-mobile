// SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
// SPDX-FileCopyrightText: 2025 Luis Büchi <luis.buechi@kdemail.net>
// SPDX-License-Identifier: GPL-2.0-or-later

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.components 3.0 as PlasmaComponents

import org.kde.kwin 3.0 as KWinComponents

MouseArea {
    id: root
    readonly property int count: repeater.count

    required property real shellTopMargin
    required property real shellBottomMargin

    required property var taskSwitcher
    readonly property var taskSwitcherState: taskSwitcher.state
    readonly property var taskSwitcherHelpers: taskSwitcher.taskSwitcherHelpers

    property int taskInteractingCount: 0

    // account for system header and footer offset (center the preview image)
    // if there's too little space space for the task scrub icons, shift it slightly above center to make space
    readonly property real taskYBase: {
        let headerHeight = shellTopMargin;
        let footerHeight = shellBottomMargin;
        let diff = headerHeight - footerHeight;

        let baseY = (taskSwitcher.height / 2) - (taskSwitcherHelpers.taskHeight / 2) - (taskSwitcherHelpers.taskHeaderHeight / 2);

        return baseY + diff / 2 - shellTopMargin;
    }
    readonly property real taskY: {
        let trackFingerYOffsetClamped = 0;
        if (taskSwitcherHelpers.isScaleClamped && (taskSwitcherState.wasInActiveTask || taskSwitcherHelpers.taskDrawerOpened)) {
            trackFingerYOffsetClamped = taskSwitcherHelpers.trackFingerYOffset;
        }

        let scrubModeOffset = 0;
        if (taskSwitcherHelpers.isInTaskScrubMode && !taskSwitcherHelpers.currentlyBeingClosed) {
            scrubModeOffset = taskSwitcherHelpers.scrubModeOverrun;
        }

        return Math.round(taskYBase - trackFingerYOffsetClamped - scrubModeOffset);
    }

    function getTaskAt(index: int): Task {
        return repeater.itemAt(index);
    }

    function closeAll(): void {
        for (let i = 0; i < repeater.count; i++) {
            repeater.itemAt(i).closeApp();
        }
    }

    function minimizeAll(): void {
        for (let i = 0; i < repeater.count; i++) {
            let item = repeater.itemAt(i);

            // minimize window
            if (!item.window.minimized) {
                item.minimizeApp();
            }
        }
    }

    function jumpToFirstVisibleWindow(): void {
        for (let i = 0; i < repeater.count; i++) {
            let item = repeater.itemAt(i);

            if (!item.window.minimized) {
                taskSwitcherHelpers.goToTaskIndex(i);
                break;
            }
        }
    }

    // the position offset value for non-active tasks in the task drawer
    // this value is normalized and is usually set to 0, 1, or 2 (larger the number, the further they are from the active task)
    property real baseTaskOffset: 0

    // the position offset value tracked to the touch x position when opening the task drawer from the home screen
    // this allows the task switcher to move left and right without causing problems with the task offset animations
    property real homeTouchPositionX: 0

    // the touch x position value normalized between 0 and 1
    // the base value should be 0.5 for when it is on the home screen
    readonly property real touchPosition: {
        let value = 0.5
        if (taskSwitcherState.wasInActiveTask || taskSwitcherHelpers.taskDrawerOpened) {
            // since the touch position starts at 0, we add half the window width and then divide it by the full width to normalize it
            value = ((taskSwitcherHelpers.notHomeScreenState ? taskSwitcherState.touchXPosition : 0) + (taskSwitcherHelpers.windowWidth / 2)) / taskSwitcherHelpers.windowWidth
            value = Math.min(1, Math.max(0, value))
        }
        return value
    }

    // dynamic task offset animation duration based off of the touch position and task scale
    function dynamicDuration(left = true): int {
        // if the close animation is running, use the standard long duration time for consistency
        let duration = Kirigami.Units.longDuration * 1.75
        if (!taskSwitcherHelpers.closeAnim.running && taskSwitcherHelpers.notHomeScreenState && taskSwitcherHelpers.gestureState != TaskSwitcherHelpers.GestureStates.HorizontalSwipe && !taskSwitcherHelpers.isInTaskScrubMode) {
            // max out the scale at 1 so it is not too fast when opening the task drawer with the button
            let taskScale = Math.min(taskSwitcherHelpers.currentScale, 1)
            // change the duration based off of the touch position and task scale
            duration = duration * ((left ? touchPosition : (1 - touchPosition)) + 1)
        }
        return duration
    }

    // the duration is set to 0 if setOffsetDurationImmediately is true so we can skip the animation
    readonly property real taskOffsetDurationLeft: setOffsetDurationImmediately ? 0 : dynamicDuration(true)
    readonly property real taskOffsetDurationRight: setOffsetDurationImmediately ? 0 : dynamicDuration(false)

    // the easing type for the task offset animation
    property int taskOffsetEasing: Easing.InOutQuart

    // skips the animation and sets the task offset value immediately (only should be set by 'setTaskOffsetValue')
    property bool setOffsetDurationImmediately: true

    // set the task offset value with an animation unless specified otherwise
    function setTaskOffsetValue(value: int, immediately = false, taskEasing = ((taskSwitcherHelpers.notHomeScreenState || (value != 0)) && (baseTaskOffset != taskSwitcherHelpers.taskOffsetValue)) ? Easing.InOutQuart : Easing.OutQuart): void {
        if (baseTaskOffset == value && immediately) {
            baseTaskOffset = value + 1;
        }
        setOffsetDurationImmediately = immediately;
        taskOffsetEasing = taskEasing;
        baseTaskOffset = value;
    }

    transform: Scale {
        origin.x: root.width / 2
        origin.y: root.height / 2
        xScale: root.taskSwitcherHelpers.currentScale
        yScale: root.taskSwitcherHelpers.currentScale
    }

    onClicked: {
        // if tapped on the background, then hide
        taskSwitcher.hide();
    }

    onPressedChanged: {
        // disable if being closed or opened to prevent bugs
        if (!taskSwitcherHelpers.currentlyBeingOpened && !taskSwitcherHelpers.currentlyBeingClosed && pressed) {
            // ensure animations aren't running when finger is pressed
            taskSwitcherHelpers.cancelAnimations();
        }
    }

    Repeater {
        id: repeater
        model: root.taskSwitcher.tasksModel

        // left margin from root edge such that the task is centered
        readonly property real leftMargin: (root.width / 2) - (root.taskSwitcherHelpers.taskWidth / 2)

        delegate: Task {
            id: task
            readonly property int currentIndex: model.index
            readonly property bool isCurrentTask: currentIndex == root.taskSwitcherHelpers.currentDisplayTask

            // this is the x-position with respect to the list
            property real listX: root.taskSwitcherHelpers.xPositionFromTaskIndex(currentIndex)
            Behavior on listX {
                NumberAnimation {
                    duration: Kirigami.Units.longDuration
                    easing.type: Easing.InOutQuad
                }
            }

            // the animated task offset value (always will be 0 if it is the current task in the task drawer)
            property real taskOffsetNormalized: (root.baseTaskOffset * ((root.taskSwitcherHelpers.taskDrawerOpened && isCurrentTask) ? 0 : 1))
            Behavior on taskOffsetNormalized {
                NumberAnimation {
                    duration: root.taskSwitcherHelpers.currentDisplayTask > task.currentIndex ? root.taskOffsetDurationRight : root.taskOffsetDurationLeft
                    easing.type: root.taskOffsetEasing
                    easing.overshoot: 0.85
                }
            }

            // calculate which direction to offset
            readonly property real offsetDir: (root.taskSwitcherHelpers.currentDisplayTask > currentIndex ? -1 : 1)

            // check if this task should be offset
            readonly property real isOffScreenOffset: {
                let isOffsetBase = ((!root.taskSwitcherState.wasInActiveTask && !root.taskSwitcherHelpers.taskDrawerOpened) || !isCurrentTask) ? (root.taskSwitcherHelpers.isInTaskScrubMode && root.taskSwitcherHelpers.notHomeScreenState ? 0 : 1) : 0
                let isOffsetTaskDrawer = (currentIndex == root.taskSwitcherHelpers.currentDisplayTask ? 0 : 1)
                return root.taskSwitcherHelpers.taskDrawerOpened ? isOffsetTaskDrawer : isOffsetBase
            }

            // how far the task needs to travel to be off screen
            readonly property real scrollXOffset: Math.abs(root.taskSwitcherHelpers.xPositionFromTaskIndex(root.taskSwitcherHelpers.currentDisplayTask) - (root.taskSwitcherState.xPosition + (root.taskSwitcherState.touchXPosition / root.taskSwitcherHelpers.currentScale)))
            readonly property real offScreenOffset: (root.taskSwitcherHelpers.windowWidth * (((root.taskSwitcherHelpers.notHomeScreenState ? root.taskSwitcherState.touchXPosition : 0) * offsetDir * ((root.homeTouchPositionX == 0) ? 1 : 0) + (root.taskSwitcherHelpers.windowWidth / 2)) / root.taskSwitcherHelpers.windowWidth));


            // calculate the actual task offset
            readonly property real taskOffset: ((offScreenOffset + (root.taskSwitcherHelpers.notHomeScreenState ? scrollXOffset : 0)) / root.taskSwitcherHelpers.currentScale - (root.homeTouchPositionX * (1 - Math.max(0, Math.min(1, (taskOffsetNormalized - root.taskSwitcherHelpers.peekOffsetValue) / (root.taskSwitcherHelpers.homeOffsetValue - root.taskSwitcherHelpers.peekOffsetValue)))))) * taskOffsetNormalized * isOffScreenOffset * offsetDir

            // extra resistance calculated for non-current task in the task drawer
            readonly property real nonCurrentScaleResistance: ((isCurrentTask && root.taskSwitcherHelpers.notHomeScreenState) || root.taskSwitcherHelpers.fromButton) ? 0 : 1 - Math.min(root.taskSwitcherHelpers.currentScale, 1)
            readonly property real nonCurrentScaleXOffset: (isCurrentTask && root.taskSwitcherHelpers.notHomeScreenState) ? 0 : ((root.taskSwitcherHelpers.taskWidth) * (scale - 1) * (currentIndex - root.taskSwitcherHelpers.currentDisplayTask))
            readonly property real nonCurrentXPositionResistance: (isCurrentTask && root.taskSwitcherHelpers.notHomeScreenState) ? 0 : (root.taskSwitcherHelpers.taskWidth * (scale - 1)) * (root.taskSwitcherHelpers.notHomeScreenState ? 0.25 : 1.0) * offsetDir
            readonly property real nonCurrentYPositionResistance: (isCurrentTask && root.taskSwitcherHelpers.notHomeScreenState) ? 0 : ((taskSwitcher.height / 2)) * nonCurrentScaleResistance

            // this is the actual displayed x-position on screen
            x: listX + repeater.leftMargin - root.taskSwitcherState.xPosition - taskOffset - nonCurrentScaleXOffset + nonCurrentXPositionResistance
            y: ((root.taskSwitcherState.wasInActiveTask || root.taskSwitcherHelpers.taskDrawerOpened) ? root.taskY + nonCurrentYPositionResistance * 0.5: root.taskY / (root.taskSwitcherHelpers.fromButton ? 1 : (1 + taskOffsetNormalized * 0.075))) // add more resistance when not the current task

            scale: ((isCurrentTask && root.taskSwitcherHelpers.notHomeScreenState) || root.taskSwitcherHelpers.fromButton) ? 1 : (1 + nonCurrentScaleResistance) * (1 + taskOffsetNormalized * 0.075) // add more resistance when not the current task and resist even further if the task is offset

            // ensure current task is above others
            z: isCurrentTask ? 1 : 0

            // only show header once task switcher is opened
            showHeader: !root.taskSwitcherState.gestureInProgress && !root.taskSwitcherHelpers.currentlyBeingClosed && !root.taskSwitcherHelpers.isInTaskScrubMode

            // darken effect as task gets away from the center of the screen
            darken: {
                const distFromCentreProgress = Math.abs(x - repeater.leftMargin - (root.taskSwitcherHelpers.currentlyBeingOpened || root.taskSwitcherHelpers.currentlyBeingClosed ? (root.taskSwitcherHelpers.xPositionFromTaskIndex(root.taskSwitcherHelpers.currentDisplayTask)) - root.taskSwitcherState.xPosition : 0)) / root.taskSwitcherHelpers.taskWidth;
                const upperBoundAdjust = Math.min(0.25, distFromCentreProgress) - 0.2;
                return Math.max(0, upperBoundAdjust);
            }

            // fade out as the task closes
            opacity: root.taskSwitcherHelpers.closingFactor

            // update count of tasks being interacted with, so we know whether we are in a swipe up action
            onInteractingActiveChanged: {
                let offset = interactingActive ? 1 : -1;
                root.taskInteractingCount = Math.max(0, root.taskInteractingCount + offset);
            }

            width: root.taskSwitcherHelpers.taskWidth
            height: root.taskSwitcherHelpers.taskHeight
            previewWidth: root.taskSwitcherHelpers.previewWidth
            previewHeight: root.taskSwitcherHelpers.previewHeight

            taskSwitcher: root.taskSwitcher
        }
    }
}
