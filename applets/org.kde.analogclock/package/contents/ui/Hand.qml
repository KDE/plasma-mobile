/*
 *   Author: Marco Martin <mart@kde.org>
 *   Date: Mon Dec 6 2010, 19:01:32
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
import org.kde.plasma.graphicswidgets 0.1 as PlasmaWidgets
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.graphicslayouts 4.7 as GraphicsLayouts

PlasmaCore.SvgItem {
    id: secondHand

    property alias rotation: rotation.angle

    width: naturalSize.width
    height: naturalSize.height
    anchors.top: center.verticalCenter
    anchors.horizontalCenter: center.horizontalCenter
    svg: clockSvg
    smooth: true
    transform: Rotation {
        id: rotation
        angle: 0
        origin.x: secondHand.naturalSize.width/2; origin.y: 0;
        Behavior on angle {
            SpringAnimation { spring: 2; damping: 0.2; modulus: 360 }
        }
    }
}
