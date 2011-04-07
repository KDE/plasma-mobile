/*
 *   Copyright 2011 Marco Martin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2 or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import Qt 4.7


Rectangle {
    id: connectorRectangle

    property Item itemA
    property Item itemB

    property real connectorAngle: Math.atan((itemB.y+height/2-itemA.y)/(itemB.x-itemA.x-itemA.width/2))

    width: (itemB.x-itemA.width/2)/Math.cos(connectorAngle)
    height: 14
    radius: 7
    color: "white"
    smooth:true
    x: -width +6
    y: parent.height/2-height/2
    transform: Rotation {
        origin.x: connectorRectangle.width-6
        origin.y: 6
        angle: (180/Math.PI)*connectorAngle
    }
}