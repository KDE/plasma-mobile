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
import org.kde.qtextracomponents 0.1

 MouseEventListener {
    id: panelDragButton

    property int startY
    property int startX
    property int lastY
    property bool dragging: false
    property bool dragEnabled: true
    property int panelHeight
    property int tasksHeight
    property bool homeButtonShown: !deviceCapabilitiesSource.data["Input"]["hasHomeButton"]

    PlasmaCore.Svg {
        id: iconSvg
        imagePath: "icons/start"
    }

    PlasmaCore.DataSource {
        id: deviceCapabilitiesSource
        engine: "org.kde.devicecapabilities"
        interval: 0
        connectedSources: ["Input"]
    }

    PlasmaCore.SvgItem {
        id: iconItem
        svg: iconSvg
        elementId: "start-here"
        width: homeButtonShown ? height : 0
        height: parent.panelHeight
        visible: homeButtonShown
        enabled: !homeScreen.windowActive
        opacity: enabled ? 1 : 0.3
        anchors {
            right: parent.right
            bottom: parent.bottom
            bottomMargin: background.margins.bottom
            rightMargin: homeButtonShown ? height * 1.4 - height : 0
        }
        MouseArea {
            anchors.fill: parent
            onClicked: homeScreen.focusActivityView()
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
    }
    onPositionChanged: {
        if (!panelDragButton.dragEnabled ) {
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
            topSlidingPanel.y = Math.min(0, (topSlidingPanel.y + mouse.screenY - lastY))
        }
        lastY = mouse.screenY
    }

    onReleased: {

        panelDragButton.dragEnabled = true
        disableTimer.running = false
        dragging = false
        var oldState = systrayPanel.state
        systrayPanel.state = "none"

        // if more than half of pick & launch panel is visible then make it totally visible.
        if ((topSlidingPanel.y > -(systrayPanel.height - topSlidingPanel.windowListArea.height)/2) ) {
            //the biggest one, Launcher
            systrayPanel.state = "Launcher"
        } else if ((oldState == "Hidden" && systrayPanel.height + topSlidingPanel.y > panelDragButton.tasksHeight/2) ||
                   (systrayPanel.height + topSlidingPanel.y > (panelDragButton.tasksHeight / 5) * 6)) {
            //show only the taskbar: require a smaller quantity of the screen uncovered when the previous state is hidden
            systrayPanel.state = "Tasks"
        } else {
            //Only the small top panel
            systrayPanel.state = "Hidden"
        }
        startY = -1
        startX = -1
        lastY = -1
    }
}
