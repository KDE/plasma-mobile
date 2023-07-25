/*
 *   SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Layouts 1.15

import org.kde.taskmanager 0.1 as TaskManager
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.private.mobileshell 1.0 as MobileShell

MobileShell.Flickable {
    id: root
    
    required property var homeScreenState
    
    // we use flickable solely for capturing flicks, not positioning elements
    contentWidth: width + 99999
    contentHeight: height + 99999
    contentX: startContentX
    contentY: startContentY
    
    readonly property real startContentX: contentWidth / 2
    readonly property real startContentY: contentHeight / 2

    // update position from flickable movement
    property real oldContentX
    property real oldContentY
    onContentXChanged: {
        homeScreenState.updatePositionWithOffset(contentX - oldContentX, 0);
        oldContentX = contentX;
    }
    onContentYChanged: {
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
    onFlickStarted: {
        homeScreenState.cancelEditModeForItemsRequested();
        root.cancelFlick();
    }
    
    onDraggingChanged: {
        if (!dragging) {
            resetPosition();
            if (!homeScreenState.animationsRunning) {
                homeScreenState.updateState();
            }
        } else {
            homeScreenState.cancelAnimations();
        }
    }
    
    function resetPosition() {
        oldContentX = startContentX;
        contentX = startContentX;
        oldContentY = startContentY;
        contentY = startContentY;
    }
}

