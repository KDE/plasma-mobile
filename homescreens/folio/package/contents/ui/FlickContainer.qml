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

Flickable {
    id: root
    
    required property var homeScreenState
    
    // we use flickable solely for capturing flicks, not positioning elements
    contentWidth: width + 99999
    contentHeight: height + 99999
    contentX: startContentX
    contentY: startContentY
    
    readonly property real startContentX: contentWidth / 2
    readonly property real startContentY: contentHeight / 2
    
    property bool positionChangedDueToFlickable: false
    
    // ensure that flickable is not moving when other sources are changing position
    Connections {
        target: root.homeScreenState
        
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
    
    // update position from flickable movement
    property real oldContentX
    property real oldContentY
    onContentXChanged: {
        positionChangedDueToFlickable = true;
        homeScreenState.updatePositionWithOffset(contentX - oldContentX, 0);
        oldContentX = contentX;
    }
    onContentYChanged: {
        positionChangedDueToFlickable = true;
        homeScreenState.updatePositionWithOffset(0, -(contentY - oldContentY));
        oldContentY = contentY;
    }
    
    onMovementStarted: homeScreenState.cancelAnimations();
    onMovementEnded: {
        if (!homeScreenState.animationsRunning) {
            homeScreenState.updateState();
        }
        resetPosition();
    }
    onFlickEnded: {
        homeScreenState.cancelEditModeForItemsRequested()
        resetPosition();
    }
    
    onDragStarted: homeScreenState.cancelEditModeForItemsRequested()
    onDragEnded: homeScreenState.cancelEditModeForItemsRequested()
    onFlickStarted: homeScreenState.cancelEditModeForItemsRequested()
    
    onDraggingChanged: {
        if (!dragging) {
            cancelMovement();
            resetPosition();
            if (!homeScreenState.animationsRunning) {
                homeScreenState.updateState();
            }
        } else {
            homeScreenState.cancelAnimations();
        }
    }
    
    function cancelMovement() {
        root.cancelFlick();
        
        // HACK: cancelFlick() doesn't seem to cancel flicks...
        root.flick(-horizontalVelocity, -verticalVelocity);
    }
    
    function resetPosition() {
        positionChangedDueToFlickable = true;
        oldContentX = startContentX;
        contentX = startContentX;
        oldContentY = startContentY;
        contentY = startContentY;
    }
}

