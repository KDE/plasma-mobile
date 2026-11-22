// SPDX-FileCopyrightText: 2021-2023 Devin Lin <devin@kde.org>
// SPDX-FileCopyrightText: 2025 Luis Büchi <luis.buechi@kdemail.net>
// SPDX-License-Identifier: LGPL-2.0-or-later

pragma ComponentBehavior: Bound

import QtQuick

import org.kde.plasma.private.mobileshell.taskswitcherplugin as TaskSwitcherPlugin
import "../logic"

Flickable {
    // TODO flickable is busted, it refuses to actually do any flicks with touch input, only works with mouse
    // we work around this somewhat by snapping to the nearest task in which direction it was moving when letting go
    // no matter how far away we are (and no matter how fast we go)
    id: root

    required property TaskSwitcher taskSwitcher
    readonly property TaskSwitcherPlugin.MobileTaskSwitcherState taskSwitcherState: taskSwitcher.state
    readonly property TaskSwitcherGeometry geometry: taskSwitcher.geometry
    readonly property TaskSwitcherController controller: taskSwitcher.controller

    // we use flickable solely for capturing flicks, not positioning elements
    // the horizontal distance we can swipe in one flick
    // The drag is always within the bounds (the start position is in the middle), as the layout
    // has its own overscroll resistance.
    readonly property real dragRange: geometry.layout.contentWidth + width
    contentWidth: dragRange * 2 + width
    contentHeight: height
    contentX: startContentX

    readonly property real startContentX: dragRange
    onStartContentXChanged: {
        if (!dragging && !moving) {
            resetPosition();
        }
    }
    property bool movingRight: false // TODO needed for flickable not flicking workaround
    property bool resettingPosition: false

    // update position from horizontal flickable movement
    property real oldContentX
    onContentXChanged: {
        if (resettingPosition) {
            oldContentX = contentX;
            return;
        }

        // disable if animations are running to prevent bugs
        if (taskSwitcherState.closing) {return}

        if (moving) {
            // TODO whenever flicking actually works this should probably be swapped with
            // a minimum velocity after which it should snap to the nearest task
            controller.navigator.xPosition += contentX - oldContentX;
        }
        movingRight = contentX < oldContentX;
        oldContentX = contentX;
    }

    onMovementStarted: {
        if (taskSwitcherState.closing) {return}
        oldContentX = contentX;
        movingRight = false;
        controller.cancelAnimations();
    }
    onMovementEnded: {
        if (taskSwitcherState.closing) {return}
        controller.snapToNearestTaskWorkaround(movingRight);
        resetPosition();
    }

    onFlickStarted: {
        if (taskSwitcherState.closing) {return}
        root.cancelFlick();
    }

    onDraggingChanged: {
        if (taskSwitcherState.closing) {return}
        if (dragging) {
            oldContentX = contentX;
            movingRight = false;
            controller.cancelAnimations();
        } else {
            resetPosition();
        }
    }

    function resetPosition(): void {
        resettingPosition = true;
        cancelFlick();
        oldContentX = startContentX;
        contentX = startContentX;
        movingRight = false;
        Qt.callLater(() => {
            oldContentX = contentX;
            resettingPosition = false;
        });
    }
}
