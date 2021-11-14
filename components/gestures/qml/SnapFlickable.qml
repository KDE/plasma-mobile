/*
 *  SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.15

Flickable {
    id: flickable
    
    property var horizontalSnapPositions: []
    
    property var verticalSnapPositions: []
    
    property bool horizontalSnapEnabled: false
    
    property bool verticalSnapEnabled: false
    
    readonly property real velocityThreshold: 500 // pixels per second
    readonly property bool belowXVelocityThreshold: Math.abs(horizontalVelocity) < Math.abs(velocityThreshold)
    readonly property bool belowYVelocityThreshold: Math.abs(verticalVelocity) < Math.abs(velocityThreshold)
    
    function snapHorizontally() {
        if (horizontalSnapEnabled) {
            let points = [0, contentWidth].concat(horizontalSnapPositions);
            points.sort();
            
            console.log(points);
            
            let closestX = 0, closestDist = Math.abs(closestX - contentX);
                
            // check snap positions
            for (let curX of points) {
                if (closestDist > Math.abs(curX - contentX)) {
                    closestX = curX;
                    closestDist = Math.abs(curX - contentX);
                }
            }
            
            console.log("snapping to " + closestX + ", current contentX: " + contentX);
            console.log("duration: " + (horizontalVelocity > 0 ? 1000 * (closestDist / horizontalVelocity) : 200) + ", xvelocity: " + horizontalVelocity);
            
            contentXAnim.to = closestX;
            contentXAnim.duration = horizontalVelocity > 0 ? 1000 * (closestDist / horizontalVelocity) : 200;
            contentXAnim.restart();
        }
    }
    
    function snapVertically() {
        if (verticalSnapEnabled) {
            let closestY = 0, closestDist = Math.abs(closestY - contentY);
                
            // check other bound
            if (closestDist < Math.abs(contentHeight - contentY)) {
                closestY = contentHeight;
                closestDist = Math.abs(contentHeight - contentY);
            }
            
            // check snap positions
            for (curY in verticalSnapPositions) {
                if (closestDist < Math.abs(curY - contentY)) {
                    closestY = curY;
                    closestDist = Math.abs(curY - contentY);
                }
            }
            
            contentYAnim.to = closestY;
            contentYAnim.duration = verticalVelocity > 0 ? closestDist / verticalVelocity : 100;
            contentYAnim.restart();
        }
    }
    
    onBelowXVelocityThresholdChanged: {
        if (belowXVelocityThreshold && !draggingHorizontally) {
            console.log("xvelocity: " + horizontalVelocity);
            snapHorizontally();
        }
    }
    
    onBelowYVelocityThresholdChanged: {
        if (belowYVelocityThreshold && !draggingVertically) {
            snapVertically();
        }
    }
    
    //onDraggingHorizontallyChanged: {
        //if (draggingHorizontally) {
            //contentXAnim.stop();
        //} else {
            //snapHorizontally();
        //}
    //}
    
    //onDraggingVerticallyChanged: {
        //if (draggingVertically) {
            //contentYAnim.stop();
        //} else {
            //snapVertically();
        //}
    //}
    
    NumberAnimation on contentX {
        id: contentXAnim
        easing.type: Easing.InOutQuad
    }
    
    NumberAnimation on contentY {
        id: contentYAnim
        easing.type: Easing.InOutQuad
    }
} 
