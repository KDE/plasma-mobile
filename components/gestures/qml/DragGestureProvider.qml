/*
 *  SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.15

import org.kde.plasma.private.gestures 0.1

/*
   Evaluates end velocity (velocity at the moment the gesture ends) and travelled
   distance (delta between finger down and finger up positions) to determine
   whether the drag should continue by itself towards completion (auto-complete)
   after the finger has left the touchscreen.
 */
DragVelocityProvider {
    id: root
    
    /**
     * This property holds the position of the gesture in pixels.
     * 
     * The default is 0, set this property if a different starting position is desired.
     */
    property real position: 0

    /**
     * This property holds the smaller of the two snap positions.
     */
    required property real lesserSnapPosition
    
    /**
     * This property holds the larger of the two snap positions.
     */
    required property real greaterSnapPosition
    
    /**
     * Ending a drag at any point before this threshold will need some positive velocity
     * (i.e., towards the set direction) to get auto-completion and ending a drag at any point after this
     * threshold will need some negative velocity to avoid auto-completion.
     */
    property real dragThresholdPercent: 0.2

    /**
     * Speed needed to get auto-completion for an hypothetical flick of length zero.
     * 
     * This requirement is gradually reduced as flicks gets longer until it reaches
     * a value of zero for flicks of dragThreshold length.
     * 
     * in pixels per second
     */
    property real speedThreshold: 70

    /**
     * The duration of a snap animation. Default is 150ms.
     */
    property real snapDuration: 150
    
    property real __dragIncreasingThreshold: lesserSnapPosition + dragThresholdPercent * (greaterSnapPosition - lesserSnapPosition)
    property real __dragDecreasingThreshold: greaterSnapPosition - dragThresholdPercent * (greaterSnapPosition - lesserSnapPosition)
    property real __dragIncreasingProgress: Math.min(1, Math.max(0, (position - lesserSnapPosition) / (greaterSnapPosition - lesserSnapPosition)))
    property real __startPosition

    onDragStart: __startPosition = position;
    
    onDragEnd: {
        if (shouldAutoCompleteIncreasing()) {
            positionAnimation.to = greaterSnapPosition;
        } else if (shouldAutoCompleteDecreasing()) {
            positionAnimation.to = lesserSnapPosition;
        } else if (position < __dragIncreasingThreshold) {
            positionAnimation.to = lesserSnapPosition;
        } else {
            positionAnimation.to = greaterSnapPosition;
        }
        positionAnimation.restart();
    }
    
    onDragValueChanged: {
        if (root.dragging) {
            position = __startPosition + dragValue;
        }
    }
    
    property var __positionAnimation: SmoothedAnimation {
        id: positionAnimation
        target: root
        property: "position"
        duration: root.snapDuration
    }
    
    // Returns whether the drag should continue by itself until completed in the positive direction.
    function shouldAutoCompleteIncreasing() {
        if (__dragIncreasingProgress > dragThresholdPercent) {
            return false;
        }
        return root.dragVelocity >= __calculateMinimumVelocityForAutoCompletionIncreasing();
    }

    function __calculateMinimumVelocityForAutoCompletionIncreasing() {
        // Minimum velocity when a drag total distance is zero
        var v0 = speedThreshold;
        var deltaPos = root.dragValue;
        return v0 - ((speedThreshold / __dragIncreasingThreshold) * deltaPos);
    }
    
    // Returns whether the drag should continue by itself until completed in the positive direction.
    function shouldAutoCompleteDecreasing() {
        if ((1 - __dragIncreasingProgress) > dragThresholdPercent) {
            return false;
        }
        return -root.dragVelocity >= __calculateMinimumVelocityForAutoCompletionDecreasing();
    }

    function __calculateMinimumVelocityForAutoCompletionDecreasing() {
        // Minimum velocity when a drag total distance is zero
        var v0 = speedThreshold;
        var deltaPos = root.dragValue;
        return v0 - ((speedThreshold / __dragDecreasingThreshold) * deltaPos);
    }
}

