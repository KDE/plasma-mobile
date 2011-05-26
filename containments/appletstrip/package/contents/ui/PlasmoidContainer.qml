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

import QtQuick 1.0
import org.kde.plasma.core 0.1 as PlasmaCore

PlasmaCore.FrameSvgItem {
    id: plasmoidContainer
    anchors.top: appletsRow.top
    anchors.bottom: appletsRow.bottom

    //FIXME: this is due to the disappear anim managed by the applet itslef
    scale: applet.scale

    property QGraphicsWidget applet

    onAppletChanged: {
        applet.appletDestroyed.connect(appletDestroyed)
        applet.parent = plasmoidContainer

        appletTimer.running = true
    }

    //FIXME: this delay is becuase backgroundHints gets updated only after a while in qml applets
    Timer {
        id: appletTimer
        interval: 250
        repeat: false
        running: false
        onTriggered: {
            if (applet.backgroundHints != 0) {
                plasmoidContainer.imagePath = "widgets/background"
            } else {
                plasmoidContainer.imagePath = "invalid"
            }
            applet.backgroundHints = "NoBackground"

            applet.x = plasmoidContainer.margins.left
            applet.y = plasmoidContainer.margins.top
            height = appletsRow.height
            width = Math.max(main.width/appletColumns, applet.minimumSize.width + plasmoidContainer.margins.left + plasmoidContainer.margins.right)
            applet.width = width - plasmoidContainer.margins.left - plasmoidContainer.margins.right
            applet.height = height - plasmoidContainer.margins.top - plasmoidContainer.margins.bottom - runButton.height
        }
    }

    function appletDestroyed()
    {
        plasmoidContainer.destroy()
    }

    PlasmaCore.Svg {
        id: iconsSvg
        imagePath: "widgets/configuration-icons"
    }

    MoveButton {
        anchors {
            left: parent.left
            bottom: parent.bottom
            leftMargin: plasmoidContainer.margins.left
            bottomMargin: plasmoidContainer.margins.bottom
        }
    }

    ActionButton {
        id: runButton
        anchors {
            right: parent.right
            bottom: parent.bottom
            rightMargin: plasmoidContainer.margins.right
            bottomMargin: plasmoidContainer.margins.bottom
        }
        svg: iconsSvg
        elementId: "maximize"
        backgroundVisible: false
        z: applet.z + 1

        action: applet.action("run associated application")
    }

    ExtraActions {
        anchors {
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
            bottomMargin: plasmoidContainer.margins.bottom
        }
        z: applet.z + 1
    }

    onHeightChanged: {
        if (applet) {
            applet.height = height
            var ratio = applet.preferredSize.width/applet.preferredSize.height
            applet.width = main.width/appletColumns
            width = applet.width
        }
    }
}