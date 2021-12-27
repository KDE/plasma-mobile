/*
 *   SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Layouts 1.15

import org.kde.taskmanager 0.1 as TaskManager
import org.kde.plasma.core 2.1 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.private.nanoshell 2.0 as NanoShell
import org.kde.plasma.private.mobileshell 1.0 as MobileShell

Flickable {
    id: root
    
    required property var taskSwitcherState
    
    // we use flickable solely for capturing flicks, not positioning elements
    contentWidth: width + 99999
    contentHeight: height
    contentX: startContentX
    
    readonly property real startContentX: contentWidth / 2
    
    property bool positionChangedDueToFlickable: false
    
    // ensure that flickable is not moving when other sources are changing position
    Connections {
        target: root.taskSwitcherState
        
        onXPositionChanged: {
            if (!root.positionChangedDueToFlickable) {
                root.cancelMovement();
            }
            root.positionChangedDueToFlickable = true;
        }
        onYPositionChanged: {
            if (!root.positionChangedDueToFlickable) {
                root.cancelMovement();
            }
            root.positionChangedDueToFlickable = true;
        }
    }
    
    // update position from horizontal flickable movement
    property real oldContentX
    onContentXChanged: {
        positionChangedDueToFlickable = true;
        taskSwitcherState.xPosition += contentX - oldContentX;
        oldContentX = contentX;
    }
    
    onMovementStarted: taskSwitcherState.cancelAnimations();
    onMovementEnded: {
        resetPosition();
        taskSwitcherState.updateState();
    }
    onFlickEnded: {
        resetPosition();
        taskSwitcherState.updateState();
    }
    
    onDraggingChanged: {
        if (!dragging) {
            cancelMovement();
            resetPosition();
            taskSwitcherState.updateState();
        } else {
            taskSwitcherState.cancelAnimations();
        }
    }
    
    function cancelMovement() {
        root.cancelFlick();
        
        // HACK: cancelFlick() doesn't seem to cancel flicks...
        root.flick(-horizontalVelocity, 0);
    }
    
    function resetPosition() {
        positionChangedDueToFlickable = true;
        oldContentX = startContentX;
        contentX = startContentX;
    }
}
