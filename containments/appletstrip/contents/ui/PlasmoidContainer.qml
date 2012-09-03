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
 *   GNU Library General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 1.0
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents

PlasmaCore.FrameSvgItem {
    id: plasmoidContainer
    anchors.top: appletsRow.top
    anchors.bottom: appletsRow.bottom
    width: main.width/appletColumns

    //FIXME: this is due to the disappear anim managed by the applet itslef
    scale: applet.scale

    property alias applet: appletContainer.applet

    onAppletChanged: {
        applet.appletDestroyed.connect(appletDestroyed)
        appletTimer.running = true
    }

    MobileComponents.AppletContainer {
        id: appletContainer

        anchors {
            fill: parent
            leftMargin: parent.margins.left
            rightMargin: parent.margins.right
            topMargin: parent.margins.top
            bottomMargin: parent.margins.bottom + runButton.height
        }
        onAppletChanged: {
            appletTimer.running = true
        }
    }


    Timer {
        id: appletTimer
        interval: 250
        repeat: false
        running: false
        onTriggered: {
            if (applet.backgroundHints != 0) {
                plasmoidContainer.imagePath = "widgets/background"
            } else {
                plasmoidContainer.imagePath = "widgets/translucentbackground"
            }
            applet.backgroundHints = "NoBackground"
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

    MobileComponents.ActionButton {
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
}
