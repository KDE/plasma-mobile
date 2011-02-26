/***************************************************************************
 *   Copyright 2010 Alexis Menard <menard@kde.org>                         *
 *   Copyright 2010 Artur Duque de Souza <asouza@kde.org>                  *
 *   Copyright 2010 Marco Martin <notmart@gmail.com>                       *
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

Rectangle {
    id: unlockscreen;
    width: 800;
    height: 480;

    color: "gray";
    opacity: 0.3;

    Rectangle {
        id: dragwidget;

        y: unlockscreen.height/2 - height/2;
        x: unlockscreen.width/4;
        width: (unlockscreen.width/4) * 2;
        height: 50;
        radius: 8;
        opacity: 0.7;
        smooth: true;
        gradient: Gradient {
            GradientStop { position: 0.0; color: "black" }
            GradientStop { position: 1.0; color: "white" }
        }

        Rectangle {
            id: draghandle;
            state: "locked";

            x: 0;
            y: 0;
            width: 80;
            height: parent.height;
            radius: 8;
            opacity: 0.7;
            smooth: true;
            gradient: Gradient {
                GradientStop { position: 0.0; color: "white" }
                GradientStop { position: 1.0; color: "black" }
            }

            MouseArea {
                id: hintregion;
                anchors.fill: parent;

                drag.target: parent;
                drag.axis: "XAxis"
                drag.minimumX: 0;
                drag.maximumX: dragwidget.width-draghandle.width;

                onPressed: {
                    draghandle.state = 'dragging';
                }

                onReleased: {
                    if (draghandle.state != 'dragging')
                        return;
                    var target = dragwidget.width/2;
                    if (draghandle.x > target) {
                        draghandle.state = 'unlocked';
                    } else {
                        draghandle.state = 'locked';
                    }
                }
            }


            states: [
                State {
                    name: "locked";
                    PropertyChanges {
                        target: draghandle;
                        x: 0;
                    }
                },
                State {
                    name: "unlocked";
                    PropertyChanges {
                        target: draghandle;
                        x: dragwidget.width - draghandle.width;
                    }
                },
                State {
                    name: "dragging"
                }
            ]

            transitions: Transition {
                NumberAnimation { properties: "x"; easing.type: "InOutQuad"; duration: 200 }
            }
        }
    }




}
