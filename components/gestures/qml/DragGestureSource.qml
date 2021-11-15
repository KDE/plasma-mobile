/*
 *  SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.15

/**
 * Provides events for an DragGestureProvider or DragVelocityProvider
 */
MouseArea {
    id: root

    required property DragVelocityProvider target
    
    property int orientation: Qt.Vertical
    property point __pressedPosition: Qt.point(0, 0)
    property bool clickValidated: true
    property bool zeroVelocityCounts: false

    propagateComposedEvents: true
    
    onMouseYChanged: {
        if (orientation == Qt.Vertical) {
            target.dragValue = mouseY - __pressedPosition.y;
            if (target.dragValue != 0 && root.pressed) {
                target.dragging = true;
            }
        }
    }
    
    onMouseXChanged: {
        if (orientation == Qt.Horizontal) {
            target.dragValue = mouseX - __pressedPosition.x;
            if (target.dragValue != 0 && root.pressed) {
                target.dragging = true;
            }
        }
    }
    
    onPositionChanged: {
        if (orientation == Qt.Vertical) {
            target.__sourcePositionChange(mouse.y);
        } else {
            target.__sourcePositionChange(mouse.x);
        }
        
        if (!root.containsMouse) {
            clickValidated = false;
        }
    }

    onPressed: {
        __pressedPosition = Qt.point(mouse.x, mouse.y);
        if (orientation == Qt.Vertical) {
            target.__sourcePress(mouse.y);
        } else {
            target.__sourcePress(mouse.x);
        }
        root.clickValidated = true;
        //mouse.accepted = false;
    }

    onReleased: {
        target.dragging = false;
        __pressedPosition = Qt.point(mouse.x, mouse.y);
        //mouse.accepted = false;
    }

    onCanceled: {
        target.dragging = false;
    }
}


