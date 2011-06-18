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

Item {
    id: panelDragButton
    state: slidingPanel.state
    width: height

    PlasmaCore.SvgItem {
        svg: PlasmaCore.Svg {
            imagePath: "widgets/arrows"
        }
        elementId: "up-arrow"
        width: height
        height: parent.height
        anchors.bottom: dashboardIcon.top
    }
    PlasmaCore.SvgItem {
        id: dashboardIcon
        x: 0
        svg: PlasmaCore.Svg {
            imagePath: "icons/dashboard"
        }
        elementId: "dashboard-show"
        width: height
        height: parent.height
    }

    MouseArea {
        anchors.fill: parent
        property int startY
        property bool dragging: false
        drag {
            target: dashboardIcon
            maximumX: 0
            minimumX: 0
            minimumY: 0
            maximumY: height
        }
        onPressed: {
            if (slidingPanel.state == "Hidden") {
                dragging = true
                startY = mouse.y
                slidingPanel.state = "Peek"
            }
        }
        onPositionChanged: {
            if (dragging) {
                slidingPanel.y = -slidingPanel.height + main.height + (mouse.y - startY) + 20
            }
        }
        onReleased: {
            dragging = false
            if (slidingPanel.state == "Peek" && slidingPanel.y > -slidingPanel.height/3) {
                slidingPanel.state = "Full"
            } else if (slidingPanel.state != "Peek") {
                slidingPanel.state = "Hidden"
            } else if (mouse.y - startY > 10) {
                slidingPanel.state = "Tasks"
            } else {
                slidingPanel.state = "Full"
            }
        }
    }

    states: [
        State {
            name: "Full"
            PropertyChanges {
                target: dashboardIcon
                y: height
            }
        },
        State {
            name: "Hidden"
            PropertyChanges {
                target: dashboardIcon
                y: 0
            }
        },
        State {
            name: "Tasks"
            PropertyChanges {
                target: dashboardIcon
                y: height
            }
        }
    ]
    transitions: Transition {
        PropertyAnimation {
            properties: "y"
            duration: 250
            easing.type: Easing.InOutQuad
        }
    }
}
