// SPDX-FileCopyrightText: 2021-2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick 2.15
import QtQuick.Layouts 1.15

import org.kde.plasma.core 2.1 as PlasmaCore

Flickable {
    id: root
    
    property int position: 0
    
    required property real keypadHeight
    
    signal opened()
    
    function cancelAnimations() {
        positionAnim.stop();
    }
    
    function goToOpenPosition() {
        positionAnim.to = keypadHeight;
        positionAnim.restart();
    }
    
    function goToClosePosition() {
        positionAnim.to = 0;
        positionAnim.restart();
    }
    
    function updateState() {
        // don't update state if at end
        if (position <= 0 || position >= keypadHeight) return;
        
        if (movingUp) {
            goToOpenPosition();
        } else {
            goToClosePosition();
        }
    }
    
    NumberAnimation on position {
        id: positionAnim
        duration: PlasmaCore.Units.veryLongDuration
        easing.type: Easing.OutExpo
        
        onFinished: {
            if (root.position === keypadHeight) {
                root.opened();
            }
        }
    }
    
    // we use flickable solely for capturing flicks, not positioning elements
    contentWidth: width
    contentHeight: height * 2
    contentX: 0
    contentY: startContentY
    
    readonly property real startContentY: contentHeight / 2
    
    property int oldPosition: position
    property bool movingUp: false 
    
    onPositionChanged: {
        movingUp = oldPosition <= position;
        oldPosition = position;
    }
    
    // update position from flickable movement
    property real oldContentY
    onContentYChanged: {
        position = Math.max(0, Math.min(keypadHeight, position + (contentY - oldContentY)));
        oldContentY = contentY;
    }
    
    onMovementStarted: cancelAnimations();
    onMovementEnded: {
        if (!positionAnim.running) {
            updateState();
        }
        resetPosition();
    }
    
    onFlickStarted: root.cancelFlick()
    onFlickEnded: resetPosition();
    
    onDraggingChanged: {
        if (!dragging) {
            resetPosition();
            if (!positionAnim.running) {
                root.updateState();
            }
        } else {
            cancelAnimations();
        }
    }
    
    function resetPosition() {
        oldContentY = startContentY;
        contentY = startContentY;
    }
}


