/***************************************************************************
 *   Copyright 2010 Lim Yuen Hoe <yuenhoe@hotmail.com>                     *
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
    id: systraypanel;
    state: "passive";
    signal activated();
    signal shrinkFinished();
    signal enlargeFinished();

    Image {
        id: activityimage;
        anchors.fill: parent;
        source: "images/activitypanel.png";
    }

    states: [
        State {
            name: "active";
            PropertyChanges {
                target: systraypanel;
                height: 100;
                width: parent.width;
            }
            PropertyChanges {
                target: systraypanelarea;
                z : 0;
            }
        },
        State {
            name: "passive";
            PropertyChanges {
                target: systraypanel;
                height: 40;
                width: 300;
            }
            PropertyChanges {
                target: systraypanelarea;
                z : 500;
            }
        }
    ]


    transitions: [
        Transition {
            from: "passive"; to: "active";
            SequentialAnimation {
                NumberAnimation {
                    properties: "x, width, height";
                    duration: 500;
                    easing.type: Easing.InOutQuad;
                }
                ScriptAction {
                    script: enlargeFinished();
                }
            }
        },
        Transition {
            from: "active"; to: "passive";
            SequentialAnimation {
                NumberAnimation {
                    properties: "x, width, height";
                    duration: 500;
                    easing.type: Easing.InOutQuad;
                }
                ScriptAction {
                    script: shrinkFinished();
                }
            }
        }
    ]
    MouseArea {
        id: systraypanelarea;
        anchors.fill: parent;
        onClicked: {
            systraypanel.state = (systraypanel.state == "active") ? "passive" : "active";
            systraypanel.activated();
        }
        z: 500;
    }
}
