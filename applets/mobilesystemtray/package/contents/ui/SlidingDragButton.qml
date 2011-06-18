/*
 *   Copyright 2011 Marco Martin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
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
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents

Item {
    id: panelDragButton

    PlasmaCore.Svg {
        id: iconSvg
        imagePath: "icons/dashboard"
    }

    PlasmaCore.SvgItem {
        svg: iconSvg
        elementId: "dashboard-show"
        width: height
        anchors {
            top: parent.top
            left: parent.left
            bottom:parent.bottom
        }
    }

    PlasmaCore.SvgItem {
        svg: iconSvg
        elementId: "dashboard-show"
        width: height
        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
            bottom:parent.bottom
        }
    }

    PlasmaCore.SvgItem {
        svg: iconSvg
        elementId: "dashboard-show"
        width: height
        anchors {
            top: parent.top
            right: parent.right
            bottom:parent.bottom
        }
    }

    MobileComponents.MouseEventListener {
        anchors.fill: parent
        property int startY
        property bool dragging: false

        onPressed: {
            dragging = true
            startY = mouse.screenY
            //slidingPanel.state = "Peek"
        }
        onPositionChanged: {
            if (dragging) {
                slidingPanel.y = -slidingPanel.height + main.height + (mouse.screenY ) + 20
            }
        }
        onReleased: {
            dragging = false
            slidingPanel.state = "none"
            if (slidingPanel.y > -slidingPanel.height/4) {
                slidingPanel.state = "Full"
            } else if (slidingPanel.y > -slidingPanel.height/2) {
                slidingPanel.state = "Tasks"
            } else {
                slidingPanel.state = "Hidden"
            }
        }
    }
}
