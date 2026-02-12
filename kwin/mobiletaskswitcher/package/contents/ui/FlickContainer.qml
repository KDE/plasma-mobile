// SPDX-FileCopyrightText: 2021-2023 Devin Lin <devin@kde.org>
// SPDX-FileCopyrightText: 2025 Luis Büchi <luis.buechi@kdemail.net>
// SPDX-License-Identifier: LGPL-2.0-or-later

pragma ComponentBehavior: Bound

import QtQuick

Flickable {
    // TODO flickable is busted, it refuses to actually do any flicks with touch input, only works with mouse
    // we work around this somewhat by snapping to the nearest task in which direction it was moving when letting go
    // no matter how far away we are (and no matter how fast we go)
    id: root

    required property var taskSwitcherState
    required property var taskSwitcherHelpers
    required property int tasksCount

    // we use flickable solely for capturing flicks, not positioning elements
    // the horizontal distance we can swipe in one flick
    contentWidth: (taskSwitcherHelpers.taskWidth + taskSwitcherHelpers.taskSpacing) * tasksCount
    contentHeight: height
    contentX: startContentX


    readonly property real startContentX: (taskSwitcherHelpers.taskWidth + taskSwitcherHelpers.taskSpacing) * tasksCount
    property bool movingRight: false // TODO needed for flickable not flicking workaround

    // update position from horizontal flickable movement
    property real oldContentX
    onContentXChanged: {
        // disable if animations are running to prevent bugs
        if (taskSwitcherHelpers.currentlyBeingClosed) {return}

        if (moving) {
            // TODO whenever flicking actually works this should probably be swapped with
            // a minimum velocity after which it should snap to the nearest task
            taskSwitcherState.xPosition += contentX - oldContentX;
        }
        movingRight = contentX < oldContentX;
        oldContentX = contentX;
    }

    onMovementStarted: {
        if (taskSwitcherHelpers.currentlyBeingClosed) {return}
        taskSwitcherHelpers.cancelAnimations();
    }
    onMovementEnded: {
        if (taskSwitcherHelpers.currentlyBeingClosed) {return}
        taskSwitcherHelpers.snapToNearestTaskWorkaround(movingRight);
        resetPosition();
    }

    onFlickStarted: {
        if (taskSwitcherHelpers.currentlyBeingClosed) {return}
        root.cancelFlick();
    }
    onFlickEnded: {
        // taskSwitcherHelpers.snapToNearestTaskWorkaround(movingRight);
        // resetPosition();
    }

    onDraggingChanged: {
        if (taskSwitcherHelpers.currentlyBeingClosed) {return}
        if (dragging) {
            taskSwitcherHelpers.cancelAnimations();
        } else {
            resetPosition();
        }
    }

    function resetPosition(): void {
        oldContentX = startContentX;
        contentX = startContentX;
    }
}
