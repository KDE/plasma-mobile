/*
 *  SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.15

/**
 * Provides events for an DragGestureProvider or DragVelocityProvider.
 *
 */

DragHandler {
    id: root

    property int orientation: Qt.Vertical
    
    required property DragVelocityProvider gestureProvider
    
    property real __startPosition: 0 // correct for dragThreshold so that we don't have a "jump" at the beginning of a gesture
    property bool __startActive: false
    
    onTranslationChanged: {
        if (__startActive) { // when the gesture actually starts with the first movement
            __startPosition = orientation == Qt.Vertical ? translation.y : translation.x;
            root.gestureProvider.__sourcePress(__startPosition);
            __startActive = false;
        }
        
        if (orientation == Qt.Vertical) {
            root.gestureProvider.__sourcePositionChange(translation.y);
            root.gestureProvider.dragValue = translation.y - __startPosition;
        } else {
            root.gestureProvider.__sourcePositionChange(translation.x);
            root.gestureProvider.dragValue = translation.x - __startPosition;
        }
        
        if (root.gestureProvider.dragValue != 0 && active) {
            root.gestureProvider.dragging = true;
        }
    }
    
    onActiveChanged: {
        if (active) {
            __startActive = true;
        } else {
            // touch release event
            __startActive = false;
            root.gestureProvider.dragging = false;
            
            // reset position of root
            //root.target.x = 0;
            //root.target.y = 0;
        }
    }
}
