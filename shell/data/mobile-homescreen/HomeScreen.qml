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
    id: homescreen;
    objectName: "homeScreen";
    x: 0;
    y: 0;
    width: 800;
    height: 480;
    signal transitionFinished();
    state : "Normal";

    Flipable {
        id : flipable;
        objectName: "containments";
        property int angle: 0;
        anchors.fill: parent
        state : "Front360";
        property bool flipable : true;
        property bool transforming : false;
        signal transformingChanged(bool transforming);

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
            Item {
                id: mainSlot;
                objectName: "mainSlot";
                x: 0;
                y: 0;
                width: homescreen.width;
                height: homescreen.height;
                transformOrigin : Item.Center;
            }

            Item {
                id : spareSlot;
                objectName: "spareSlot";
                x: 0;
                y: -homescreen.height;
                width: homescreen.width;
                height: homescreen.height;
            }
        }
        back: Item {
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
                    script: flipable.transformingChanged(true);
                }
                NumberAnimation {
                    properties: "angle";
                    duration: 800;
                    easing.type: "Linear";
                }
                ScriptAction {
                    script: flipable.transformingChanged(false);
                }
            }
        },
        Transition {
            from: "Front360"
            to:"Back540"
            SequentialAnimation {
                ScriptAction {
                    script: flipable.transformingChanged(true);
                }
                NumberAnimation {
                    properties: "angle";
                    duration: 800;
                    easing.type: "Linear";
                }
                ScriptAction {
                    script: flipable.transformingChanged(false);
                }
            }
        },
        Transition {
            from: "Front0"
            to:"Back180"
            SequentialAnimation {
                ScriptAction {
                    script: flipable.transformingChanged(true);
                }
                NumberAnimation {
                    properties: "angle";
                    duration: 800;
                    easing.type: "Linear";
                }
                ScriptAction {
                    script: flipable.transformingChanged(false);
                }
            }
        },
        Transition {
            from: "Front0"
            to:"Back540"
            SequentialAnimation {
                ScriptAction {
                    script: flipable.transformingChanged(true);
                }
                NumberAnimation {
                    properties: "angle";
                    duration: 800;
                    easing.type: "Linear";
                }
                ScriptAction {
                    script: flipable.transformingChanged(false);
                }
            }
        },
        Transition {
            from: "Back180"
            to:"Front360"
            SequentialAnimation {
                ScriptAction {
                    script: flipable.transformingChanged(true);
                }
                NumberAnimation {
                    properties: "angle";
                    duration: 800;
                    easing.type: "Linear";
                }
                ScriptAction {
                    script: flipable.transformingChanged(false);
                }
            }
        },
        Transition {
            from: "Back180"
            to:"Front0"
            SequentialAnimation {
                ScriptAction {
                    script: flipable.transformingChanged(true);
                }
                NumberAnimation {
                    properties: "angle";
                    duration: 800;
                    easing.type: "Linear";
                }
                ScriptAction {
                    script: flipable.transformingChanged(false);
                }
            }
        },
        Transition {
            from: "Back540"
            to:"Front0"
            SequentialAnimation {
                ScriptAction {
                    script: flipable.transformingChanged(true);
                }
                NumberAnimation {
                    properties: "angle";
                    duration: 800;
                    easing.type: "Linear";
                }
                ScriptAction {
                    script: flipable.transformingChanged(false);
                }
            }
        },
        Transition {
            from: "Back540"
            to: "Front360"
            SequentialAnimation {
                ScriptAction {
                    script: flipable.transformingChanged(true);
                }
                NumberAnimation {
                    properties: "angle";
                    duration: 800;
                    easing.type: "Linear";
                }
                ScriptAction {
                    script: flipable.transformingChanged(false);
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
                    scale: 1;
                }
                PropertyChanges {
                    target: mainSlot;
                    y: 0;
                }
                PropertyChanges {
                    target: spareSlot;
                    scale: 0.9;
                }
                PropertyChanges {
                    target: spareSlot;
                    y: -homescreen.height;
                }

            },
            State {
                name: "Slide"
                PropertyChanges {
                    target: spareSlot;
                    scale: 1;
                }
                PropertyChanges {
                    target: spareSlot;
                    y: 0;
                }
                PropertyChanges {
                    target: mainSlot;
                    scale: 0.9;
                }
                PropertyChanges {
                    target: mainSlot;
                    y: homescreen.height;
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
                    script: transitionFinished();
                }
            }
        }

    SystrayPanel {
        id: systraypanel;
        objectName: "systraypanel";

        anchors.horizontalCenter: homescreen.horizontalCenter;
        y: 0;
    }
    ActivityPanel {
        id: activitypanel;
        objectName: "activitypanel";

        anchors.left: parent.left;
        anchors.right: parent.right;
        y: parent.height - height;
    }

    Rectangle {
        id: activitypanelbottom;
        objectName: "activitypanelbottom";

        color: "black";
        anchors.left: homescreen.left;
        anchors.right: homescreen.right;
        anchors.top: activitypanel.bottom;
        height: homescreen.height/2;
    }

    Connections {
        target: activitypanel;

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
                flipable.transformingChanged(flipable.transforming);
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
}
