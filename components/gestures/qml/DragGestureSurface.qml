/*
 *  SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.15

/**
 * Provides events for an DragGestureProvider or DragVelocityProvider.
 * 
 * Use this component as the parent of the component you want gestures to be detected from.
 */

Item {
    id: root

    property bool enabled: true
    property int orientation: Qt.Vertical
    
    required property DragVelocityProvider target
    
    DragHandler {
        id: dragHandler
        enabled: root.enabled
        
        property real startPosition: 0 // correct for dragThreshold so that we don't have a "jump" at the beginning of a gesture
        property bool startActive: false
        
        onTranslationChanged: {
            if (startActive) { // when the gesture actually starts with the first movement
                startPosition = orientation == Qt.Vertical ? translation.y : translation.x;
                root.target.__sourcePress(startPosition);
                startActive = false;
            }
            
            if (orientation == Qt.Vertical) {
                root.target.__sourcePositionChange(translation.y);
                root.target.dragValue = translation.y - startPosition;
            } else {
                root.target.__sourcePositionChange(translation.x);
                root.target.dragValue = translation.x - startPosition;
            }
            
            if (root.target.dragValue != 0 && active) {
                root.target.dragging = true;
            }
        }
        
        onActiveChanged: {
            if (active) {
                startActive = true;
            } else {
                // touch release event
                startActive = false;
                root.target.dragging = false;
                
                // reset position of root
                root.x = 0;
                root.y = 0;
            }
        }
    }
}
