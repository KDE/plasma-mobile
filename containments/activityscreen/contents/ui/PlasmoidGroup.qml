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

import QtQuick 1.0
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents
import "plasmapackage:/code/LayoutManager.js" as LayoutManager

ItemGroup {
    id: plasmoidGroup
    scale: plasmoid.scale
    canResizeHeight: true
    title: applet.name
    minimumWidth: Math.max(LayoutManager.cellSize.width,
                           appletContainer.minimumWidth +
                           plasmoidGroup.contents.anchors.leftMargin +
                           plasmoidGroup.contents.anchors.rightMargin)

    minimumHeight: Math.max(LayoutManager.cellSize.height,
                            appletContainer.minimumHeight +
                            plasmoidGroup.contents.anchors.topMargin +
                            plasmoidGroup.contents.anchors.bottomMargin)

    property alias applet: appletContainer.applet


    MobileComponents.AppletContainer {
        id: appletContainer
        anchors.fill: plasmoidGroup.contents
        onAppletChanged: {
            applet.appletDestroyed.connect(appletDestroyed)
            appletTimer.running = true
        }
        function appletDestroyed()
        {
            LayoutManager.setSpaceAvailable(plasmoidGroup.x, plasmoidGroup.y, plasmoidGroup.width, plasmoidGroup.height, true)
            plasmoidGroup.destroy()
        }
    }

    MobileComponents.ActionButton {
        svg: configIconsSvg
        elementId: "close"
        iconSize: Math.max(16, plasmoidGroup.titleHeight - 2)
        backgroundVisible: false
        visible: action.enabled
        action: applet.action("remove")
        anchors {
            right: plasmoidGroup.contents.right
            bottom: plasmoidGroup.contents.top
            bottomMargin: 4
        }
        Component.onCompleted: {
            action.enabled = true
        }
    }

    MobileComponents.ActionButton {
        svg: configIconsSvg
        elementId: "configure"
        iconSize: Math.max(16, plasmoidGroup.titleHeight - 2)
        backgroundVisible: false
        visible: action.enabled
        action: applet.action("configure")
        anchors {
            left: plasmoidGroup.contents.left
            bottom: plasmoidGroup.contents.top
            bottomMargin: 4
        }
        Component.onCompleted: {
            action.enabled = true
        }
    }


    //FIXME: this delay is becuase backgroundHints gets updated only after a while in qml applets
    Timer {
        id: appletTimer
        interval: 250
        repeat: false
        running: false
        onTriggered: {
            if (applet.backgroundHints != 0) {
                plasmoidGroup.imagePath = "widgets/background"
            } else {
                plasmoidGroup.imagePath = "widgets/translucentbackground"
            }
            applet.backgroundHints = "NoBackground"
        }
    }
}
