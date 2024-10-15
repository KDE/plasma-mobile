// SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick 2.15

import org.kde.kirigami 2.20 as Kirigami
import org.kde.private.mobileshell.taskswitcher 1.0 as TaskSwitcherData

import org.kde.kwin 3.0 as KWinComponents

/**
 * State object for the task switcher.
 */
QtObject {
    id: root

    // TaskSwitcher item component
    // We assume that the taskSwitcher is the size of the entire screen.
    required property var taskSwitcher
    property var state: taskSwitcher.state
    required property var stateClass

    // task switcher peek and pop setting for when it is toggled from the home screen
    readonly property real peekOffsetValue: 1.85
    readonly property real homeOffsetValue: 2.6
    readonly property real taskOffsetValue: 1.5

    // the index of the last task to be closed
    // this will get reset to -1 in TaskSwitcher.qml when the TasksCount changes
    property int lastClosedTask: -1

    // this will only gets set to the currentTaskIndex when the gesture starts
    // this helps remove visual glitches as the gesture animations play out and the currentTaskIndex changes
    property int currentDisplayTask: state.currentTaskIndex

    // how much the the task will resist shrinking
    // value of 1 will match the y position resistance one to one
    readonly property real scaleResistance: 0.5

    // direction of the movement
    readonly property bool gestureMovingRight: state.xVelocity > 0
    readonly property bool gestureMovingUp: state.yVelocity < 0

    readonly property bool currentlyBeingOpened: state.gestureInProgress || openAnim.running
    readonly property bool currentlyBeingClosed: closeAnim.running || openAppAnim.running

    // yPosition when the task switcher is completely open
    readonly property real openedYPosition: (taskSwitcher.height - taskHeight) / 2

    // yPosition threshold below which opening the task switcher should be undone and returned to the previously active task
    readonly property real undoYThreshold: openedYPosition / 2

    // the height threshold where if the yPosition is above this value the task switch will return home
    readonly property real heightThreshold: windowHeight * 0.55

    // whether the switcher is opened or not
    readonly property bool taskDrawerOpened: state.status == TaskSwitcherData.TaskSwitcherState.Active

    // This is true when the task drawer is already opened or if within an app
    readonly property bool notHomeScreenState: state.wasInActiveTask || taskDrawerOpened

    // set to true if the taskSwitcher is opened by the navbar button
    property bool fromButton: false

    // gets set to true after 1 milliseconds
    property bool taskSwitchCanLaunch: false

    // whether the switcher has already triggered haptic feedback or not
    // we don't want to continuously send haptics, just once is enough
    property bool hasVibrated: false

    // The current gesture state to decide what will happpen when it is completed
    enum GestureStates {
        Undecided,
        HorizontalSwipe,
        TaskSwitcher,
        Home
    }
    property int gestureState: TaskSwitcherHelpers.GestureStates.Undecided

    // if the touch has reached the height threshold
    property bool reachedHeightThreshold: false

    // made as variables to keep x anim in task list and task scrub icon list in sync
    property int xAnimDuration: Kirigami.Units.longDuration * 2
    property int xAnimEasingType: Easing.OutExpo

    // ~~ measurement constants ~~

    // dimensions of a real window on the screen
    readonly property real windowHeight: taskSwitcher.height - taskSwitcher.topMargin - taskSwitcher.bottomMargin
    readonly property real windowWidth: taskSwitcher.width - taskSwitcher.leftMargin - taskSwitcher.rightMargin

    // dimensions of the task previews
    readonly property real previewHeight: windowHeight * scalingFactor
    readonly property real previewWidth: windowWidth * scalingFactor
    readonly property real previewAspectRatio: previewWidth / previewHeight
    readonly property real taskHeight: previewHeight + taskHeaderHeight
    readonly property real taskWidth: previewWidth

    // spacing between each task preview
    readonly property real taskSpacing: Kirigami.Units.gridUnit

    // height of the task preview header
    readonly property real taskHeaderHeight: Kirigami.Units.gridUnit * 2 + Kirigami.Units.smallSpacing * 2

    // finger position y with resistance
    readonly property real trackFingerYOffset: {
        if (taskSwitcherHelpers.isScaleClamped) {
            let directTrackingOffset = openedYPosition * 0.2
            if (root.state.yPosition < openedYPosition + directTrackingOffset) {
                // Allow the task list to move further up than the fully opened position
                return root.state.yPosition - openedYPosition;
            } else {
                // but make it more reluctant the further up it goes
                let overDragProgress = (root.state.yPosition - directTrackingOffset - openedYPosition) / openedYPosition;
                // Base formula is 1-2.3^(-progress) which asymptotically approaches 1
                return (1 - Math.pow(2.3, -overDragProgress)) * openedYPosition + directTrackingOffset;
            }
        } else {
            return 0;
        }
    }

    // the scaling factor of the window preview compared to the actual window
    // we need to ensure that window previews always fit on screen
    readonly property real scalingFactor: {
        let candidateFactor = 0.6;
        let candidateTaskHeight = windowHeight * candidateFactor + taskHeaderHeight;
        let candidateTaskWidth = windowWidth * candidateFactor;

        let candidateHeight = (candidateTaskWidth / windowWidth) * windowHeight;
        if (candidateHeight > windowHeight) {
            return candidateTaskHeight / windowHeight;
        } else {
            return candidateTaskWidth / windowWidth;
        }
    }

    // the closing factor during the closing of the switcher
    property real closingFactor: 1

    // scaling factor during the closing of the switcher
    property real closingScalingFactor: 1

    // scale of the task list (based on the progress of the swipe up gesture)
    readonly property real currentScale: {
        let maxScale = 1 / scalingFactor;
        let subtract = (maxScale - 1) * ((Math.min(root.state.yPosition, openedYPosition) + trackFingerYOffset * scaleResistance) / openedYPosition)
        let finalScale = Math.min(maxScale, maxScale - subtract);

        // if closing scaling factor is below 1 we want it to override the other scale
        // to allow for a smoother closing animation
        if (closingScalingFactor < 1 && (root.state.wasInActiveTask || root.taskDrawerOpened)) {
            return closingScalingFactor;
        }

        return finalScale;
    }
    readonly property bool isScaleClamped: root.state.yPosition > openedYPosition

    readonly property real taskScrubDistance: windowWidth / (2 * 6) // formula says how many tasks can be scrubbed through in half of the window width
    property bool isInTaskScrubMode: false

    // ~~ signals and functions ~~

    // cancel all animated moving, as another flick source is taking over
    signal cancelAnimations()
    onCancelAnimations: {
        openAppAnim.stop();
        closeAnim.stop();
        closeScaleAnim.stop();
        closeFactorAnim.stop();
        xAnim.stop();
    }

    function getTaskIndexFromWindow(window) {
        for (let i = 0; i < taskSwitcher.tasksModel.rowCount(); i++) {
            const modelWindow = taskSwitcher.tasksModel.data(taskSwitcher.tasksModel.index(i, 0), Qt.DisplayRole);
            if (modelWindow == window) {
                return i;
            }
        }
        return 0;
    }

    function getTaskIndexFromXPosition() {
        let candidateIndex = Math.round(-root.state.xPosition / (taskSpacing + taskWidth));
        return Math.max(0, Math.min(taskSwitcher.tasksCount - 1, candidateIndex));
    }

    // TODO either use updateTaskIndex to always have the "newest current task index" in the state var or use "getNearestTaskIndex", not both it's redundant
    function updateTaskIndex() {
        // only set if not gesture currently in progress to prevent glitching
        if (!(state.gestureInProgress || root.closeAnim.running || root.openAppAnim.running) || root.isInTaskScrubMode) {
            root.state.currentTaskIndex = getTaskIndexFromXPosition();
        }
    }

    function open() {
        root.gestureState = TaskSwitcherHelpers.GestureStates.TaskSwitcher;
        openAnim.restart();

        // update the task offset position
        taskList.setTaskOffsetValue(0, false, Easing.OutQuart);
    }

    function close() {
        // update the task offset position
        taskList.setTaskOffsetValue(homeOffsetValue + 0.25, false, Easing.Linear);

        root.gestureState = TaskSwitcherHelpers.GestureStates.Undecided;
        cancelAnimations();
        closingScalingFactor = currentScale;
        closeAnim.restart();
        closeScaleAnim.restart();
        closeFactorAnim.restart();
    }

    function openApp(index, window, duration = Kirigami.Units.shortDuration, horizontalEasing = Easing.OutBack) {
        // cancel any opening animations ongoing
        openAnim.stop();
        cancelAnimations();

        animateGoToTaskIndex(index, duration);
        openAppAnim.restart();
        KWinComponents.Workspace.activeWindow = window
    }

    // get the xPosition where the task will be centered on the screen
    function xPositionFromTaskIndex(index) {
        return -index * (taskWidth + taskSpacing);
    }

    // instantly go to the task index
    function goToTaskIndex(index) {
        root.state.xPosition = xPositionFromTaskIndex(index);
    }

    // go to the task index, animated
    function animateGoToTaskIndex(index, duration = Kirigami.Units.longDuration * 2, easing = Easing.OutExpo) {
        xAnimDuration = duration;
        xAnimEasingType = easing;
        xAnim.to = xPositionFromTaskIndex(index) - (gestureState == TaskSwitcherHelpers.GestureStates.HorizontalSwipe && !state.gestureInProgress && notHomeScreenState ? taskSpacing / 2 : 0);
        xAnim.restart();
    }

    function getNearestTaskIndex() {
        let newTaskIndex = getTaskIndexFromXPosition();
        let currentTaskIndexPosition = xPositionFromTaskIndex(root.state.currentTaskIndex);
        if (root.state.xPosition > currentTaskIndexPosition) {
            // moving to task further to the right
            if (newTaskIndex != root.state.currentTaskIndex) {
                // reset back to current task index
                return root.state.currentTaskIndex;
            } else {
                // animate snapping to new task index
                return Math.max(0, newTaskIndex);
            }
        } else {
            // moving to task further to the left
            if (newTaskIndex != root.state.currentTaskIndex) {
                // animate snapping to new task index
                return Math.min(taskSwitcher.tasksCount - 1, newTaskIndex);
            } else {
                // reset back to current task index
                return root.state.currentTaskIndex;
            }
        }
    }
    function snapToNearestTask() {
        let index = getNearestTaskIndex();
        animateGoToTaskIndex(index);
    }

    // This is a workaround for flickable not actually flicking, so we just snap to the next task
    // based on old movement direction, ignoring momentum (because flickable doesn't give us any momentum)
    function snapToNearestTaskWorkaround(movingRight) {
        let currentTaskIndexPosition = xPositionFromTaskIndex(root.state.currentTaskIndex);
        if (root.state.xPosition > currentTaskIndexPosition) {
            if (movingRight) {
                animateGoToTaskIndex(root.state.currentTaskIndex);
            } else {
                animateGoToTaskIndex(Math.max(0, root.state.currentTaskIndex - 1));
            }
        } else {
            if (movingRight) {
                animateGoToTaskIndex(Math.min(taskSwitcher.tasksCount - 1, root.state.currentTaskIndex + 1));
            } else {
                animateGoToTaskIndex(root.state.currentTaskIndex);
            }
        }
    }

    // ~~ property animators ~~

    property var xAnim: NumberAnimation {
        target: root.state
        property: "xPosition"
        duration: xAnimDuration
        easing.type: xAnimEasingType
    }

    property var openAnim: NumberAnimation {
        target: root.state
        property: "yPosition"
        to: openedYPosition
        duration: 250
        easing.type: Easing.OutQuart

        onFinished: {
            if (!isInTaskScrubMode) {
                root.state.status = stateClass.Active;
            }
        }
    }

    // TODO: This animation should ideally be replaced by some
    // speed tracking to track finger movement better. Until then
    // InBack at least pretends to go in the finger move direction
    property var closeAnim: NumberAnimation {
        target: root.state
        property: "yPosition"
        to: 0
        duration: Kirigami.Units.longDuration
        easing.type: Easing.InBack

        onFinished: {
            root.state.status = stateClass.Inactive;
            taskSwitcher.instantHide();
        }
    }

    property var closeScaleAnim: NumberAnimation {
        target: root
        property: "closingScalingFactor"
        to: 0.1
        duration: Kirigami.Units.longDuration
        easing.type: Easing.InQuad

        onStopped: {
            closingScalingFactor = 1;
        }
    }

    property var closeFactorAnim: NumberAnimation {
        target: root
        property: "closingFactor"
        to: 0
        duration: Kirigami.Units.longDuration
        easing.type: Easing.InQuad
    }

    property var openAppAnim: NumberAnimation {
        target: root.state
        property: "yPosition"
        to: 0
        duration: 300
        easing.type: Easing.OutQuint
        onFinished: {
            root.state.status = stateClass.Inactive;
            taskSwitcher.instantHide();
        }
    }
}
