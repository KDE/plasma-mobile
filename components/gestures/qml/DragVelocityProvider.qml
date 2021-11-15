/*
 *  SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.15

import org.kde.plasma.private.gestures 0.1

QtObject {
    id: root
    
    property bool dragging: false
    property bool zeroVelocityCounts: false
    
    property real dragVelocity: 0
    property real dragValue: 0
    
    signal dragStart()
    signal dragEnd()
    
    property var __dragEvents: []
    property var __dateTime: new function() {
        this.getCurrentTimeMs = function() {return new Date().getTime()}
    }
    
    onDraggingChanged: {
        if (dragging) {
            dragStart();
        } else {
            dragEnd();
        }
    }
    
    function updateSpeed() {
        var totalSpeed = 0;
        for (var i = 0; i < __dragEvents.length; i++) {
            totalSpeed += __dragEvents[i][2];
        }

        if (zeroVelocityCounts || Math.abs(totalSpeed) > 0.001) {
            dragVelocity = totalSpeed / __dragEvents.length * 1000;
        }
    }

    function cullOldDragEvents(currentTime) {
        // cull events older than 50 ms but always keep the latest 2 events
        for (var numberOfCulledEvents = 0; numberOfCulledEvents < __dragEvents.length-2; numberOfCulledEvents++) {
            // __dragEvents[numberOfCulledEvents][0] is the dragTime
            if (currentTime - __dragEvents[numberOfCulledEvents][0] <= 50) break;
        }

        __dragEvents.splice(0, numberOfCulledEvents);
    }

    function getEventSpeed(currentTime, position) {
        if (__dragEvents.length != 0) {
            var lastDrag = __dragEvents[__dragEvents.length-1];
            var duration = Math.max(1, currentTime - lastDrag[0]);
            return (position - lastDrag[1]) / duration;
        } else {
            return 0;
        }
    }
    
    function pushDragEvent(position) {
        let currentTime = __dateTime.getCurrentTimeMs();
        __dragEvents.push([currentTime, position, getEventSpeed(currentTime, position)]);
        cullOldDragEvents(currentTime);
        updateSpeed();
    }

    function __sourcePositionChange(position) {
        if (dragging) {
            pushDragEvent(position);
        }
    }
    
    function __sourcePress(position) {
        __dragEvents = [];
        pushDragEvent(position);
    }
}
