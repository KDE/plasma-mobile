// SPDX-FileCopyrightText: 2013 Canonical Ltd. <legal@canonical.com>
// SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-3.0-only

import QtQuick 2.15

/**
 * Component that is able to measure velocity based on position change events.
 */

QtObject {
    id: root

    property bool zeroVelocityCounts: false

    property real velocity: 0

    function changePosition(position) {
        __pushDragEvent(position);
    }

    function startMeasure(position) {
        __dragEvents = [];
        __pushDragEvent(position);
    }

//BEGIN internal

    property var __dragEvents: []
    property var __dateTime: new function() {
        this.getCurrentTimeMs = function() {return new Date().getTime()}
    }

    function __updateSpeed() {
        var totalSpeed = 0;
        for (var i = 0; i < __dragEvents.length; i++) {
            totalSpeed += __dragEvents[i][2];
        }

        if (zeroVelocityCounts || Math.abs(totalSpeed) > 0.001) {
            velocity = totalSpeed / __dragEvents.length * 1000;
        }
    }

    function __cullOldDragEvents(currentTime) {
        // cull events older than 50 ms but always keep the latest 2 events
        for (var numberOfCulledEvents = 0; numberOfCulledEvents < __dragEvents.length-2; numberOfCulledEvents++) {
            // __dragEvents[numberOfCulledEvents][0] is the dragTime
            if (currentTime - __dragEvents[numberOfCulledEvents][0] <= 50) break;
        }

        __dragEvents.splice(0, numberOfCulledEvents);
    }

    function __getEventSpeed(currentTime, position) {
        if (__dragEvents.length != 0) {
            var lastDrag = __dragEvents[__dragEvents.length-1];
            var duration = Math.max(1, currentTime - lastDrag[0]);
            return (position - lastDrag[1]) / duration;
        } else {
            return 0;
        }
    }

    function __pushDragEvent(position) {
        let currentTime = __dateTime.getCurrentTimeMs();
        __dragEvents.push([currentTime, position, __getEventSpeed(currentTime, position)]);
        __cullOldDragEvents(currentTime);
        __updateSpeed();
    }

//END internal
}
