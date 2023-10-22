// SPDX-FileCopyrightText: 2021-2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick 2.15
import QtQuick.Layouts 1.15

import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.private.mobileshell as MobileShell

MobileShell.SwipeArea {
    id: root
    mode: MobileShell.SwipeArea.VerticalOnly
    
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
        duration: Kirigami.Units.veryLongDuration
        easing.type: Easing.OutExpo
        
        onFinished: {
            if (root.position === keypadHeight) {
                root.opened();
            }
        }
    }
    
    property int oldPosition: position
    property bool movingUp: false 
    
    onPositionChanged: {
        movingUp = oldPosition <= position;
        oldPosition = position;
    }
    
    onSwipeStarted: cancelAnimations();
    onSwipeEnded: {
        if (!positionAnim.running) {
            updateState();
        }
    }

    onSwipeMove: (totalDeltaX, totalDeltaY, deltaX, deltaY) => {
        position = Math.max(0, Math.min(keypadHeight, position - deltaY));
    }
}


