// SPDX-FileCopyrightText: 2021-2024 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick 2.15
import QtQuick.Layouts 1.15

import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.private.mobileshell as MobileShell

MobileShell.SwipeArea {
    id: root
    required property real keypadHeight

    property real animationDuration

    readonly property real openFactor: position / keypadHeight
    property real position: 0
    property bool movingUp: false
    property real __oldPosition: position

    signal opened()

    mode: MobileShell.SwipeArea.VerticalOnly

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
        duration: root.animationDuration
        easing.type: Easing.OutExpo

        onFinished: {
            if (root.position === keypadHeight) {
                root.opened();
            }
        }
    }

    onPositionChanged: {
        movingUp = __oldPosition <= position;
        __oldPosition = position;

        // Limit position to between 0 and keypadHeight
        if (position > keypadHeight) {
            position = keypadHeight;
        } else if (position < 0) {
            position = 0;
        }
    }

    function __startSwipe() {
        cancelAnimations();
    }

    function __endSwipe() {
        if (!positionAnim.running) {
            updateState();
        }
    }

    function __moveSwipe(totalDeltaX, totalDeltaY, deltaX, deltaY) {
        position = Math.max(0, Math.min(keypadHeight, position - deltaY));
    }

    onSwipeStarted: __startSwipe()
    onSwipeEnded: __endSwipe()

    onSwipeMove: __moveSwipe(totalDeltaX, totalDeltaY, deltaX, deltaY)

    onTouchpadScrollStarted: __startSwipe()
    onTouchpadScrollEnded: __endSwipe()
    onTouchpadScrollMove: __moveSwipe(totalDeltaX, totalDeltaY, deltaX, deltaY)
}


