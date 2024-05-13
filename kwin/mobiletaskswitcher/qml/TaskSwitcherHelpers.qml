// SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick 2.15

import org.kde.kirigami 2.20 as Kirigami

import org.kde.kwin 3.0 as KWinComponents

/**
 * State object for the task switcher.
 */
QtObject {
    id: root

    // TaskSwitcher item component
    // We assume that the taskSwitcher the size of the entire screen.
    required property var taskSwitcher
    property var state: taskSwitcher.state
    required property var stateClass


    // direction of the movement
    readonly property bool gestureMovingRight: state.xVelocity > 0
    readonly property bool gestureMovingUp: state.yVelocity < 0

    readonly property bool currentlyBeingOpened: state.gestureInProgress || openAnim.running
    readonly property bool currentlyBeingClosed: closeAnim.running || openAppAnim.running

    // yPosition when the task switcher is completely open
    readonly property real openedYPosition: (taskSwitcher.height - taskHeight) / 2

    // yPosition threshold below which opening the task switcher should be undone and returned to the previously active task
    readonly property real undoYThreshold: openedYPosition / 3

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

    // scale of the task list (based on the progress of the swipe up gesture)
    readonly property real currentScale: {
        let maxScale = 1 / scalingFactor;
        let subtract = (maxScale - 1) * Math.min(root.state.yPosition / openedYPosition, 1);
        let finalScale = Math.min(maxScale, maxScale - subtract);

        // animate scale only if we are *not* opening from the homescreen
        if (root.state.wasInActiveTask || !root.state.gestureInProgress) {
            return finalScale;
        }
        return 1;
    }
    readonly property bool isScaleClamped: root.state.yPosition > openedYPosition

    readonly property real taskScrubDistance: windowWidth / (2 * 6) // formula says how many tasks can be scrubbed through in half of the window width
    property bool isInTaskScrubMode: false

    // ~~ signals and functions ~~

    // cancel all animated moving, as another flick source is taking over
    signal cancelAnimations()
    onCancelAnimations: {
        openAnim.stop();
        openAppAnim.stop();
        closeAnim.stop();
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
        root.state.currentTaskIndex = getTaskIndexFromXPosition();
    }

    function open() {
        openAnim.restart();
    }

    function close() {
        closeAnim.restart();
    }

    function openApp(index, window) {
        // cancel any opening animations ongoing
        cancelAnimations();

        animateGoToTaskIndex(index, Kirigami.Units.shortDuration);
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
    function animateGoToTaskIndex(index, duration = Kirigami.Units.longDuration * 2) {
        xAnim.duration = duration;
        xAnim.to = xPositionFromTaskIndex(index);
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
        easing.type: Easing.OutBack
    }

    property var openAnim: NumberAnimation {
        target: root.state
        property: "yPosition"
        to: openedYPosition
        duration: 250
        easing.type: Easing.OutExpo

        onFinished: {
            root.state.status = stateClass.Active;
        }
    }

    property var closeAnim: NumberAnimation {
        target: root.state
        property: "yPosition"
        to: 0
        duration: Kirigami.Units.longDuration
        easing.type: Easing.InOutQuad
        onFinished: {
            root.state.status = stateClass.Inactive;
            taskSwitcher.instantHide();
        }
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
