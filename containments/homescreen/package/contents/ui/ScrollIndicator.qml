/*
 *  Copyright 2015 Marco Martin <mart@kde.org>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  2.010-1301, USA.
 */

import QtQuick 2.4
import QtGraphicalEffects 1.6
import org.kde.plasma.core 2.0 as PlasmaCore
 
PlasmaCore.SvgItem {
    id: scrollDownIndicator
    
    anchors.horizontalCenter: parent.horizontalCenter

    z: 2
    opacity: 0
    svg: arrowsSvg
    elementId: "down-arrow"
    width: units.iconSizes.large
    height: width
    layer.enabled: true
    layer.effect: DropShadow {
        cached: true
        horizontalOffset: 0
        verticalOffset: 2
        radius: 8.0
        samples: 16
        color: Qt.rgba(0, 0, 0, 0.8)
    }
    Behavior on opacity {
        OpacityAnimator {
            duration: units.longDuration * 2
            easing.type: Easing.InOutQuad
        }
    }
}
