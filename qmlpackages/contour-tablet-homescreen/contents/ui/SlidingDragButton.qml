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

 MobileComponents.MouseEventListener {
    id: panelDragButton

    property int startY
    property int startX
    property int lastY
    property bool dragging: false
    property bool dragEnabled: true
    property int panelHeight
    property int tasksHeight

    PlasmaCore.Svg {
        id: iconSvg
        imagePath: "icons/dashboard"
    }

    PlasmaCore.SvgItem {
        id: iconItem
        svg: iconSvg
        elementId: "dashboard-show"
        width: height
        height: 32
        anchors {
            right: parent.right
            bottom:parent.bottom
        }
    }

    Timer {
        id: disableTimer
        running: false
        repeat: false
        interval: 400
        onTriggered: {
            panelDragButton.dragEnabled = false
        }
    }

    onPressed: {
        startY = mouse.screenY
        startX = mouse.screenX
        lastY = mouse.screenY
        disableTimer.running = true
    }
    onPositionChanged: {
        if (!panelDragButton.dragEnabled) {
            return
        }
        //FIXME: why sometimes onPressed doesn't arrive?
        if (startY < 0 || lastY < 0) {
            startY = mouse.screenY
            startX = mouse.screenX
            lastY = mouse.screenY
        }

        //try to avoid vertical scrolling when an horizontal one is in place
        //this 32 is completely arbitrary
        if (!dragging && Math.abs(startX - mouse.screenX) > 32) {
            panelDragButton.dragEnabled = false;
        }

        if (Math.abs(startY - lastY) > 32) {
            dragging = true
            disableTimer.running = false
        }

        if (dragging) {
            slidingPanel.y = Math.min(-200, (slidingPanel.y+mouse.screenY - lastY))
        }
        lastY = mouse.screenY
    }

    onReleased: {
        panelDragButton.dragEnabled = true
        disableTimer.running = false
        dragging = false
        var oldState = systrayPanel.state
        systrayPanel.state = "none"

        //click on the handle area, always switch hidden/full
        if (mouse.y > height-35 && mouse.x > iconItem.x && Math.abs(mouse.screenY - startY) < 8) {
            if (oldState == "Hidden") {
                systrayPanel.state = "Full"
            } else {
                systrayPanel.state = "Hidden"
            }

        //the biggest one, Launcher with tag cloud
        } else if (slidingPanel.y > -100) {
            systrayPanel.state = "Launcher"

        //more than 2/3 of the screen uncovered, full
        } else if (systrayPanel.height+slidingPanel.y > systrayPanel.height/2) {
            systrayPanel.state = "Full"

        //show only the taskbar: require a smaller quantity of the screen uncovered when the previous state is hidden
        } else if ((oldState == "Hidden" && systrayPanel.height+slidingPanel.y > panelDragButton.tasksHeight/2) ||
                   (systrayPanel.height+slidingPanel.y > (panelDragButton.tasksHeight/5)*6)) {
            systrayPanel.state = "Tasks"

        //Only the small top panel
        } else {
            systrayPanel.state = "Hidden"
        }
        startY = -1
        startX = -1
        lastY = -1
    }
}
