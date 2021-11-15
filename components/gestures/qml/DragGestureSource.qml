/*
 *  SPDX-FileCopyrightText: 2013 Canonical Ltd. <legal@canonical.com>
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

    onPositionChanged: {
        if (orientation == Qt.Vertical) {
            target.__sourcePositionChange(mouse.y);
            target.dragValue = mouse.y - __pressedPosition.y;
            if (target.dragValue != 0 && root.pressed) {
                target.dragging = true;
            }
        } else {
            target.__sourcePositionChange(mouse.x);
            target.dragValue = mouse.x - __pressedPosition.x;
            if (target.dragValue != 0 && root.pressed) {
                target.dragging = true;
            }
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
    }

    onReleased: {
        target.dragging = false;
        __pressedPosition = Qt.point(mouse.x, mouse.y);
    }

    onCanceled: {
        target.dragging = false;
    }
}


