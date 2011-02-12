/*
 *   Author: Marco Martin <mart@kde.org>
 *   Date: Sun Feb 6 2011, 12:52:47
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

    width: (itemB.x-64)/Math.cos(connectorAngle) -30
    height: 12
    color: "white"
    smooth:true
    x: -width
    y: parent.height/2
    transform: Rotation {
        origin.x: connectorRectangle.width
        angle: (180/Math.PI)*connectorAngle
    }
}