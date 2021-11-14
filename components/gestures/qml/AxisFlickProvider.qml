/*
 *  SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.15

import org.kde.plasma.private.gestures 0.1

/**
 * A do-it-yourself solution for building flickable components without the QQC2 Flickable component.
 */

AxisVelocityCalculator {
    id: root

    /**
     * This property holds whether the content is being dragged.
     */
    property bool dragging

    /**
     * 
     */
    property real minPosition
    
    /**
     * 
     */
    property real maxPosition
    
    /**
     * How fast the velocity should decelerate, in pixels/second.
     */
    property real deceleration: 25
    
    /**
     * 
     */
    function snapToPointWithVelocity(point) {
        trackedPositionAnimation.stop();
        secondaryTrackedPositionAnimation.stop();
        
        let velocity = root.calculate();       
        trackedPositionAnimation.to = point;
        trackedPositionAnimation.duration = 200;

        if ((root.trackedPosition > point && velocity > 0) || (root.trackedPosition > point && velocity < 0)) { // currently in wrong direction
            trackedPositionAnimation.easing.type = Easing.InOutQuad;
            animateVelocityDeceleration(velocity);
        } else {
            trackedPositionAnimation.easing.type = Easing.OutQuad;
            trackedPositionAnimation.restart();
        }
    }
    
    /**
     * 
     */
    function snapToBounds() {
        if (root.trackedPosition > root.maxPosition) {
            snapToPointWithVelocity(root.maxPosition);
        } else if (root.trackedPosition < root.minPosition) {
            snapToPointWithVelocity(root.minPosition);
        }
        // TODO stop velocity
    }
    
    onDraggingChanged: {
        if (root.dragging) {
            root.reset();
            trackedPositionAnimation.stop();
            secondaryTrackedPositionAnimation.stop();
        } else {
            trackedPositionAnimation.duration = 0;
            animateVelocityDeceleration(root.calculate());
        }
    }

    // TODO internal
    function animateVelocityDeceleration(velocity) { // velocity in pixels/millisecond
        velocity *= 100;
        secondaryTrackedPositionAnimation.stop();
        
        console.log("velocityfound: " + velocity);
        if (isFinite(velocity) && !isNaN(velocity)) {
            // kinematics equations
            secondaryTrackedPositionAnimation.duration = Math.abs(velocity / root.deceleration);
            secondaryTrackedPositionAnimation.to = root.trackedPosition + Math.abs(velocity / root.deceleration) * (velocity / 2);
            if (secondaryTrackedPositionAnimation.to < root.minPosition) {
                secondaryTrackedPositionAnimation.to = root.minPosition;
            }
            if (secondaryTrackedPositionAnimation.to > root.maxPosition) {
                secondaryTrackedPositionAnimation.to = root.maxPosition;
            }
            
            console.log("position: " + root.trackedPosition);
            console.log("kinematics: " + secondaryTrackedPositionAnimation.duration + " " + secondaryTrackedPositionAnimation.to + " " + (Math.abs(velocity / root.deceleration) * (velocity / 2)));
            
            secondaryTrackedPositionAnimation.restart();
        }
    }
    
    NumberAnimation on trackedPosition {
        id: trackedPositionAnimation
        duration: 0
    }
    
    NumberAnimation on trackedPosition {
        id: secondaryTrackedPositionAnimation
        easing.type: Easing.OutQuad
        onFinished: {
            if (trackedPositionAnimation.duration > 0) {
                trackedPositionAnimation.restart();
            }
        }
    }
} 


