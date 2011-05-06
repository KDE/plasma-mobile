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

import QtQuick 1.0

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
            lockScreenItem.opacity = 1
        } else {
            lockScreenItem.opacity = 0
        }
    }

    //this item will define Corona::availableScreenRegion() for simplicity made by a single rectangle
    Item {
        id: availableScreenRect
        objectName: "availableScreenRect"
        anchors.fill: parent
        anchors.topMargin: 42
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
    states: [
            State {
                name: "Normal"
                PropertyChanges {
                    target: mainSlot;
                    x: 0;
                }
                PropertyChanges {
                    target: spareSlot;
                    x: -homeScreen.width;
                }

            },
            State {
                name: "Slide"
                PropertyChanges {
                    target: spareSlot;
                    x: 0;
                }
                PropertyChanges {
                    target: mainSlot;
                    x: homeScreen.width;
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
                    property: "x";
                    easing.type: "InQuad";
                    duration: 300;
                }
                NumberAnimation {
                    target: mainSlot;
                    property: "x";
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

    ActivityPanel {
        id: rightEdgePanel
        objectName: "rightEdgePanel"

        anchors.verticalCenter: parent.verticalCenter
        x: parent.width - width
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
        alternateDrag.updateDrag();
    }
    onHeightChanged: {
        alternateDrag.updateDrag();
    }

    LockScreen {
        id: lockScreenItem
        anchors.fill: parent

        onUnlocked: {
            homeScreen.locked = false
        }
    }
}
