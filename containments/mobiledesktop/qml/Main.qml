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

Flipable {
    id : flip;
    property int angle: 0;
    width : 800;
    height : 480;
    state : "Front";
    property var containment;
    transform: Rotation {
        id: rotation
        origin.x: flip.width / 2;
        origin.y: flip.height / 2;
        axis.x: 0;
        axis.y: 1;
        axis.z: 0;
        angle: flip.angle
    }

    front : containment;
    back: Rectangle {
        width: flip.width;
        height: flip.height;
        gradient: Gradient {
            GradientStop { position: 0.0; color: "white" }
            GradientStop { position: 0.5; color: "black" }
            GradientStop { position: 1.0; color: "white" }
        }
    }
    states: [
        State {
            name: "Back"
            PropertyChanges {
                target: flip;
                angle: 180;
            }
        },
        State {
            name: "Front"
            PropertyChanges {
                target: flip;
                angle: 0;
            }
        }
    ]
    transitions: Transition {
        from: "Front"
        to:"Back"
        ParallelAnimation {
            NumberAnimation {
                properties: "angle";
                duration: 800;
                easing.type: "Linear";
            }
        }
    }

    transitions: Transition {
        from: "Back"
        to:"Front"
        ParallelAnimation {
            NumberAnimation {
                properties: "angle";
                duration: 800;
                  easing.type: "Linear";
            }
          }
    }

    MouseArea {
        // change between default and 'back' states
        onClicked: flip.state = (flip.state == 'Back' ? 'Front' : 'Back')
        anchors.fill: parent
    }

}

