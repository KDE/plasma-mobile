/*
 *  SPDX-FileCopyrightText: 2013 Canonical Ltd. <legal@canonical.com>
 *  SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 *
 *  SPDX-License-Identifier: GPL-3.0
 */

import QtQuick 2.15
import org.kde.plasma.private.gestures 1.0

SwipeArea {
    id: root

    property int orientation: Qt.Vertical
    
    required property DragVelocityProvider gestureProvider
    
    onDeltaPositionChanged: {
        if (orientation == Qt.Vertical) {
            root.gestureProvider.__sourcePositionChange(deltaPosition.y);
            root.gestureProvider.dragValue = deltaPosition.y;
        } else {
            root.gestureProvider.__sourcePositionChange(deltaPosition.x);
            root.gestureProvider.dragValue = deltaPosition.x;
        }
    }
    
    onDraggingChanged: {
        if (dragging) {
            root.gestureProvider.__sourcePress(0);
        }
        root.gestureProvider.dragging = dragging;
    }
}
