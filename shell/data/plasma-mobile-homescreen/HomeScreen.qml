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

    state : "Normal";
    property bool locked: true
    signal transformingChanged(bool transforming)

    property QGraphicsWidget activeContainment
    onActiveContainmentChanged: {
        activeContainment.parent = spareSlot
        activeContainment.visible = true
        activeContainment.x = 0
        activeContainment.y = 0
        activeContainment.size = width + "x" + height
        state = "Slide"
        transformingChanged(true);
    }

    function finishTransition()
    {
        activeContainment.parent = mainSlot
        activeContainment.x = 0
        activeContainment.y = 0
        state = "Normal"
        transformingChanged(false);
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

    //this item will define Corona::availableScreenRect() and Corona::availableScreenRegion()
    Item {
        id: availableScreenRect
        objectName: "availableScreenRect"
        anchors.fill: parent
        anchors.topMargin: 32
        anchors.bottomMargin: 28

        //this properties will define "structs" for reserved screen of the panels
        property int leftReserved: 0
        property int topReserved: anchors.topMargin
        property int rightReserved: 0
        property int bottomReserved: 0
    }

    Flipable {
        id : flipable;
        objectName: "containments";
        property int angle: 0;
        anchors.fill: parent
        state : "Front360";
        property bool flipable : true;
        property bool transforming : false;
        

        transform: Rotation {
            id: rotation
            origin.x: flipable.width / 2;
            origin.y: flipable.height / 2;
            axis.x: 1;
            axis.y: 0;
            axis.z: 0;
            angle: flipable.angle
        }

        front : Item {
            anchors.fill: flipable
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
                x: 0;
                y: -homeScreen.height;
                width: homeScreen.width;
                height: homeScreen.height;
            }
        }
        back: Item {
            anchors.fill: flipable
            id: alternateSlot;
            objectName: "alternateSlot";

        }

        states: [
            State {
                name: "Back540"
                PropertyChanges {
                    target: flipable;
                    angle: 540;
                }
            },
            State {
                name: "Front0"
                PropertyChanges {
                    target: flipable;
                    angle: 0;
                }
            },
            State {
                name: "Front360"
                PropertyChanges {
                    target: flipable;
                    angle: 360;
                }
            },
            State {
                name: "Back180"
                PropertyChanges {
                    target: flipable;
                    angle: 180;
                }
            }
        ]
        transitions: [
        Transition {
            from: "Front360"
            to:"Back180"
            SequentialAnimation {
                ScriptAction {
                    script: homeScreen.transformingChanged(true);
                }
                NumberAnimation {
                    properties: "angle";
                    duration: 800;
                    easing.type: "Linear";
                }
                ScriptAction {
                    script: homeScreen.transformingChanged(false);
                }
            }
        },
        Transition {
            from: "Front360"
            to:"Back540"
            SequentialAnimation {
                ScriptAction {
                    script: homeScreen.transformingChanged(true);
                }
                NumberAnimation {
                    properties: "angle";
                    duration: 800;
                    easing.type: "Linear";
                }
                ScriptAction {
                    script: homeScreen.transformingChanged(false);
                }
            }
        },
        Transition {
            from: "Front0"
            to:"Back180"
            SequentialAnimation {
                ScriptAction {
                    script: homeScreen.transformingChanged(true);
                }
                NumberAnimation {
                    properties: "angle";
                    duration: 800;
                    easing.type: "Linear";
                }
                ScriptAction {
                    script: homeScreen.transformingChanged(false);
                }
            }
        },
        Transition {
            from: "Front0"
            to:"Back540"
            SequentialAnimation {
                ScriptAction {
                    script: homeScreen.transformingChanged(true);
                }
                NumberAnimation {
                    properties: "angle";
                    duration: 800;
                    easing.type: "Linear";
                }
                ScriptAction {
                    script: homeScreen.transformingChanged(false);
                }
            }
        },
        Transition {
            from: "Back180"
            to:"Front360"
            SequentialAnimation {
                ScriptAction {
                    script: homeScreen.transformingChanged(true);
                }
                NumberAnimation {
                    properties: "angle";
                    duration: 800;
                    easing.type: "Linear";
                }
                ScriptAction {
                    script: homeScreen.transformingChanged(false);
                }
            }
        },
        Transition {
            from: "Back180"
            to:"Front0"
            SequentialAnimation {
                ScriptAction {
                    script: homeScreen.transformingChanged(true);
                }
                NumberAnimation {
                    properties: "angle";
                    duration: 800;
                    easing.type: "Linear";
                }
                ScriptAction {
                    script: homeScreen.transformingChanged(false);
                }
            }
        },
        Transition {
            from: "Back540"
            to:"Front0"
            SequentialAnimation {
                ScriptAction {
                    script: homeScreen.transformingChanged(true);
                }
                NumberAnimation {
                    properties: "angle";
                    duration: 800;
                    easing.type: "Linear";
                }
                ScriptAction {
                    script: homeScreen.transformingChanged(false);
                }
            }
        },
        Transition {
            from: "Back540"
            to: "Front360"
            SequentialAnimation {
                ScriptAction {
                    script: homeScreen.transformingChanged(true);
                }
                NumberAnimation {
                    properties: "angle";
                    duration: 800;
                    easing.type: "Linear";
                }
                ScriptAction {
                    script: homeScreen.transformingChanged(false);
                }
            }
        }
        ]

    }

    states: [
            State {
                name: "Normal"
                PropertyChanges {
                    target: mainSlot;
                    y: 0;
                }
                PropertyChanges {
                    target: spareSlot;
                    y: -homeScreen.height;
                }

            },
            State {
                name: "Slide"
                PropertyChanges {
                    target: spareSlot;
                    y: 0;
                }
                PropertyChanges {
                    target: mainSlot;
                    y: homeScreen.height;
                }
            }
    ]

    transitions: Transition {
            from: "Normal"
            to: "Slide"
            SequentialAnimation {
                NumberAnimation {
                    target: mainSlot;
                    property: "scale";
                    easing.type: "OutQuint";
                    duration: 250;
                }
                ParallelAnimation {
                    NumberAnimation {
                        target: spareSlot;
                        property: "y";
                        easing.type: "InQuad";
                        duration: 300;
                    }
                    NumberAnimation {
                        target: mainSlot;
                        property: "y";
                        easing.type: "InQuad";
                        duration: 300;
                    }
                }
                NumberAnimation {
                    target: spareSlot;
                    property: "scale";
                    easing.type: "OutQuint";
                    duration: 250;
                }
                ScriptAction {
                    script: finishTransition();
                }
            }
        }

    SystrayPanel {
        id: topEdgePanel;
        objectName: "topEdgePanel";

        anchors.horizontalCenter: homeScreen.horizontalCenter;
        y: 0;
    }
    ActivityPanel {
        id: rightEdgePanel
        objectName: "rightEdgePanel"

        anchors.verticalCenter: parent.verticalCenter
        x: parent.width - width
    }
    LauncherPanel {
        id: bottomEdgePanel;
        objectName: "bottomEdgePanel";

        anchors.left: parent.left;
        anchors.right: parent.right;
        y: parent.height - height;
    }

    Connections {
        target: bottomEdgePanel;

        onFlipRequested : {
            if (reverse) {
                if (flipable.state == "Front0") {
                    flipable.state = "Front360";
                } else if (flipable.state == "Back180") {
                    flipable.state = "Back540";
                }

                if (flipable.state == "Front360") {
                    flipable.state = "Back180";
                } else {
                    flipable.state = "Front360";
                }
            } else {
                if (flipable.state == "Front0") {
                    flipable.state = "Front360";
                } else if (flipable.state == "Back540") {
                    flipable.state = "Back180";
                }

                if (flipable.state == "Front360") {
                    flipable.state = "Back540";
                } else {
                    flipable.state = "Front360";
                }
            }
        }

        onDragOverflow : {
            if (flipable.transforming != (degrees != 0)) {
                flipable.transforming = (degrees != 0);
                homeScreen.transformingChanged(flipable.transforming);
            }
            if (flipable.state == "Front0") {
                flipable.angle = degrees;
            } else if (flipable.state == "Back180") {
                flipable.angle = 180+degrees;
            } else if (flipable.state == "Front360") {
                flipable.angle = 360+degrees;
            //back540
            } else {
                flipable.angle = 540+degrees;
            }
        }
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
