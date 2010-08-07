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

    Rectangle {
        id: mainSlot;
        objectName: "mainSlot";
        color: "red"
        x: 0;
        y: 0;
        width: homescreen.width;
        height: homescreen.height;
        transformOrigin : Item.Center;
    }

    Rectangle {
        id : spareSlotPrev;
        objectName: "spareSlotPrev";
        color: "green"
        x: -homescreen.width;
        y: 0;
        width: homescreen.width;
        height: homescreen.height;
    }

    Rectangle {
        id : spareSlotNext;
        objectName: "spareSlotNext";
        color: "blue"
        x: homescreen.width;
        y: 0;
        width: homescreen.width;
        height: homescreen.height;
    }

    Rectangle {
        id: alternateSlot;
        color: "yellow"
        objectName: "alternateSlot";
        x: 0;
        y: alternateDrag.y + alternateDrag.height;
        width: homescreen.width;
        height: homescreen.height;
    }


    Rectangle {
        id: systraypanel;
        objectName: "systraypanel";
        color: "black"
        anchors.horizontalCenter: homescreen.horizontalCenter;
        width: 200
        height: 24
        y: 0;
    }

    Rectangle {
        id: alternateDrag;
        objectName: "alternateDrag";
        color: "black"
        state: "hidden"

        height: 32
        width: 128
        anchors.horizontalCenter: parent.horizontalCenter;
        y: parent.height - height;

        property string oldState

        MouseArea {
            id: alternateDragRegion;

            x: - 32 / 2;
            y: - 32 / 2;
            width: parent.width + 32;
            height: parent.height + 32;

            drag.target: parent;
            drag.axis: Drag.YAxis
            drag.minimumY: homescreen.height/2;
            drag.maximumY: homescreen.height-parent.height;

            onPressed: {
                alternateDrag.oldState = alternateDrag.state
                alternateDrag.state = "dragging"
                print(alternateDrag.oldState)
                print(alternateDrag.state)
            }

            onReleased: {
                if (alternateDrag.y < 2*(homescreen.height/3)) {
                    if (alternateDrag.oldState == "hidden") {
                        alternateDrag.state = "show"
                    } else {
                        alternateDrag.state = "hidden"
                    }
                } else {
                    alternateDrag.state = alternateDrag.oldState
                }
            }
        }
        
        states: [
            State {
                name: "show";
                PropertyChanges {
                    target: alternateDrag;
                    y: parent.height - alternateDrag.height;
                }
                PropertyChanges {
                    target: alternateSlot;
                    y: alternateDrag.y + alternateDrag.height - alternateSlot.height;
                }
            },
            State {
                name: "hidden";
                PropertyChanges {
                    target: alternateDrag;
                    y: parent.height - alternateDrag.height;
                }
                PropertyChanges {
                    target: alternateSlot;
                    y: -alternateSlot.height
                }
            },
            State {
                name: "dragging";
                PropertyChanges {
                    target: alternateDrag;
                    y: alternateDrag.y;
                }
                PropertyChanges {
                    target: alternateSlot;
                    y: if (alternateDrag.oldState == "show")
                           alternateDrag.y + alternateDrag.height - alternateSlot.height
                       else
                           alternateDrag.y + alternateDrag.height
                }
            }
        ]

        transitions: [
            Transition {
                from: "dragging";
                to: "hidden";
                ParallelAnimation {
                    PropertyAnimation {
                        targets: alternateDrag;
                        properties: "y";
                        duration: 400;
                        easing.type: "InOutCubic";
                    }
                    PropertyAnimation {
                        targets: alternateSlot;
                        properties: "y";
                        duration: 400;
                        easing.type: "InOutCubic";
                    }
                }
            },
            Transition {
                from: "dragging";
                to: "show";
                ParallelAnimation {
                    PropertyAnimation {
                        targets: alternateDrag;
                        properties: "y";
                        duration: 400;
                        easing.type: "InOutCubic";
                    }
                    PropertyAnimation {
                        targets: alternateSlot;
                        properties: "y";
                        duration: 400;
                        easing.type: "InOutCubic";
                    }
                }
            }
        ]
    }


}
