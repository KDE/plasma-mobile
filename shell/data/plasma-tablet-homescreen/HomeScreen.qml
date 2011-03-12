/***************************************************************************
 *   Copyright 2010 Alexis Menard <menard@kde.org>                         *
 *   Copyright 2010 Artur Duque de Souza <asouza@kde.org>                  *
 *   Copyright 2010 Marco Martin <mart@kde.org>                            *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/

import Qt 4.7

Item {
    id: homeScreen;
    objectName: "homeScreen";
    x: 0;
    y: 0;
    width: 800;
    height: 480;
    signal nextActivityRequested();
    signal previousActivityRequested();
    
    state : "Normal"
    signal transformingChanged(bool transforming)
    property bool locked: true

    property QGraphicsWidget activeContainment
    onActiveContainmentChanged: {
        activeContainment.parent = mainSlot
        activeContainment.visible = true
        activeContainment.x = 0
        activeContainment.y = 0
        activeContainment.size = width + "x" + height
        state = "Slide"
        transformingChanged(true);
    }

    onLockedChanged: {
        if (locked) {
            lockScreenItem.x = 0
            lockScreenItem.y = 0
            unlockTextAnimation.running = true
        } else if (lockScreenItem.x == 0 && lockScreenItem.y == 0) {
            lockScreenItem.x = 0
            lockScreenItem.y = homeScreen.height
        }
    }

    //this item will define Corona::screenGeometry() and Corona::availableScreenRegion()
    Item {
        id: screenGeometry
        objectName: "screenGeometry"
        anchors.fill: parent
        anchors.topMargin: 32
        anchors.bottomMargin: 28

        //this properties will define "structs" for reserved screen of the panels
        property int leftReserved: 0
        property int topReserved: anchors.topMargin
        property int rightReserved: 0
        property int bottomReserved: 0
    }

    Item {
        id: mainSlot;
        objectName: "mainSlot";
        x: 0;
        y: 0;
        width: homeScreen.width;
        height: homeScreen.height;
        transformOrigin : Item.Center;
    }

    Item {
        id : spareSlot;
        objectName: "spareSlot";
        x: -homeScreen.width;
        y: 0;
        width: homeScreen.width;
        height: homeScreen.height;
    }

    Shadow {
        id: spareSlotShadowRight
        source: "images/shadow-right.png"
        anchors.left: spareSlot.right
        anchors.leftMargin: -1
        width: 11
        height: spareSlot.height
        
    }
    Shadow {
        id: spareSlotShadowLeft
        source: "images/shadow-left.png"
        anchors.right: spareSlot.left
        anchors.rightMargin: -1
        width: 11
        height: spareSlot.height
    }

    Dragger {
        id: prevDrag

        location: "LeftEdge"
        targetItem: spareSlot

        onTransitionFinished : {
            if (state == "show") {
                thomeScreen.ransformingChanged(false);
                state = "hidden"
            }
            spareSlotShadowRight.state = "invisible"
        }
        onActivated: {
            homeScreen.transformingChanged(false);
            spareSlotShadowRight.state = "visible"
        }
    }

    Dragger {
        id: nextDrag
        objectName: "nextDrag"

        location: "RightEdge"
        targetItem: spareSlot

        onTransitionFinished : {
            if (state == "show") {
                thomeScreen.ransformingChanged(false);
                state = "hidden"
            }
            spareSlotShadowLeft.state = "invisible"
        }
        onActivated: {
            homeScreen.nextActivityRequested();
            spareSlotShadowLeft.state = "visible"
        }
    }

    Item {
        id: alternateSlot;
        objectName: "alternateSlot";
        x: 0;
        y: alternateDrag.y + alternateDrag.height;
        width: homeScreen.width;
        height: homeScreen.height;
    }
    Shadow {
        id: alternateSlotShadowTop
        source: "images/shadow-top.png"
        anchors.bottom: alternateSlot.top
        anchors.topMargin: -1
        width: alternateSlot.width
        height: 11
    }
    Shadow {
        id: alternateSlotShadowBottom
        source: "images/shadow-bottom.png"
        anchors.top: alternateSlot.bottom
        anchors.topMargin: -1
        width: alternateSlot.width
        height: 11
    }

    SystrayPanel {
        id: topEdgePanel;
        objectName: "topEdgePanel";

        anchors.horizontalCenter: homeScreen.horizontalCenter;
        y: 0;
    }

    Dragger {
        id: alternateDrag

        location: "BottomEdge"
        targetItem: alternateSlot
        onTransitionFinished : {
            alternateSlotShadowBottom.state = "invisible"
            alternateSlotShadowTop.state = "invisible"
        }

        onActivated: {
            alternateSlotShadowBottom.state = "visible"
            alternateSlotShadowTop.state = "visible"        
        }
    }

    //FIXME: this should be automatic
    onWidthChanged: {
        prevDrag.updateDrag();
        nextDrag.updateDrag();
        alternateDrag.updateDrag();
    }
    onHeightChanged: {
        prevDrag.updateDrag();
        nextDrag.updateDrag();
        alternateDrag.updateDrag();
    }

    Rectangle {
        id: lockScreenItem
        width: parent.width
        height: parent.height
        color: Qt.rgba(0, 0, 0, 0.8)

        Text {
            id: unlockText
            text: "Drag away to unlock"
            color: "white"
            anchors.centerIn: parent
            font.pixelSize: 30
            opacity: 0
            Component.onCompleted: {
                unlockTextAnimation.running = true
            }
        }
        SequentialAnimation {
            id: unlockTextAnimation
            running: false
            NumberAnimation {
                target: unlockText
                property: "opacity"
                to: 1
                duration: 1000
            }
            PauseAnimation { duration: 5000 }
            NumberAnimation {
                target: unlockText
                property: "opacity"
                to: 0
                duration: 1000
            }
        }

        MouseArea {
            anchors.fill: parent
            drag.target: lockScreenItem
            onReleased: {
                var lockedX = false
                var lockedY = false
                if (lockScreenItem.x > homeScreen.width/3) {
                    lockScreenItem.x = homeScreen.width
                } else if (lockScreenItem.x < -homeScreen.width/3) {
                    lockScreenItem.x = -homeScreen.width
                } else {
                    lockScreenItem.x = 0
                    lockedX = true
                }

                if (lockScreenItem.y > homeScreen.height/3) {
                    lockScreenItem.y = homeScreen.height
                } else if (lockScreenItem.y < -homeScreen.height/3) {
                    lockScreenItem.y = -homeScreen.height
                } else {
                    lockScreenItem.y = 0
                    lockedY = true
                }
                if (lockedX && lockedY) {
                    homeScreen.locked = true
                } else {
                    homeScreen.locked = false
                }
            }
        }
        Behavior on x {
            NumberAnimation { duration: 250 }
        }
        Behavior on y {
            NumberAnimation { duration: 250 }
        }
    }
}
