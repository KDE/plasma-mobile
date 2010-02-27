/***************************************************************************
 *   Copyright 2010 Alexis Menard <menard@kde.org>                         *
 *   Copyright 2010 Artur Duque de Souza <asouza@kde.org>                  *
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

import Qt 4.6

Rectangle {
    id: homescreen;
    x: 0;
    y: 0;
    width: 800;
    height: 480;
    color:"black"

    Item {
        id: mainSlot;
        objectName: "mainSlot";
        x: 0;
        y: 0;
        width: homescreen.width;
        height: homescreen.height;

        state : "Visible"
        transformOrigin : Item.Center
        //source: "images/background.png";

        states: [
            State {
                name: "Visible"
                PropertyChanges {
                    target: mainSlot;
                    scale: 1;
                }
                PropertyChanges {
                    target: mainSlot;
                    y: 0;
                }
            },
            State {
                name: "Hidden"
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
            from: "Visible"
            to: "Hidden"
            SequentialAnimation {
                NumberAnimation {
                    properties: "scale";
                    easing.type: "InQuad";
                    duration: 150;
                }
                NumberAnimation {
                    properties: "y";
                    easing.type: "InQuad";
                    duration: 400;
                }
            }
        }
    }

    Item {
        id : spareSlot;
        objectName: "spareSlot";
        x: 0;
        y: -homescreen.height;
        width: homescreen.width;
        height: homescreen.height;

        state : "Hidden"
        width : homescreen.width;
        height : homescreen.height;

        signal transitionFinished();

        states: [
            State {
                name: "Hidden"
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
                name: "Visible"
                PropertyChanges {
                    target: spareSlot;
                    scale: 1;
                }
                PropertyChanges {
                    target: spareSlot;
                    y: 0;
                }
            }
        ]

        transitions: Transition {
            from: "Hidden"
            to: "Visible"
            SequentialAnimation {
                NumberAnimation {
                    properties: "y";
                    easing.type: "InQuad";
                    duration: 650;
                }
                NumberAnimation {
                    properties: "scale";
                    easing.type: "InQuad";
                    duration: 150;
                }
                ScriptAction {
                    script: spareSlot.transitionFinished();
                }
            }
        }
    }

    ActivityPanel {
        id: activitypanel;
        objectName: "activitypanel";

        anchors.left: homescreen.left;
        anchors.right: homescreen.right;
        y: homescreen.height - 160;
    }
}
