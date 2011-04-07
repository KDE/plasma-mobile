/***************************************************************************
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

Image {
    id: targetShadow
    /*source: "images/shadow-top.png"
    anchors.left: dragger.target.right
    width: dragger.target.width
    height: 12*/
    state: "invisible"
    //property string location : "BottomEdge"

    

    states: [
        State {
            name: "visible";
            PropertyChanges {
                target: targetShadow;
                opacity: 1
            }
        },
        State {
            name: "invisible";
            PropertyChanges {
                target: targetShadow;
                opacity: 0
            }
        }
    ]
    transitions: [
        Transition {
            from: "visible";
            to: "invisible";

            PropertyAnimation {
                targets: targetShadow;
                properties: "opacity";
                duration: 300;
                easing.type: "InOutCubic";
            }
        },
        Transition {
            from: "invisible";
            to: "visible";

            PropertyAnimation {
                targets: targetShadow;
                properties: "opacity";
                duration: 300;
                easing.type: "InOutCubic";
            }
        }
    ]
}