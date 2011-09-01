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
import "plasmapackage:/code/LayoutManager.js" as LayoutManager

ItemGroup {
    id: plasmoidContainer
    scale: plasmoid.scale
    canResizeHeight: true

    onHeightChanged: {
        if (applet) {
            applet.height = plasmoidContainer.contents.height
        }
    }
    onWidthChanged: {
        if (applet) {
            applet.width = plasmoidContainer.contents.width
        }
    }

    function appletDestroyed()
    {
        LayoutManager.setSpaceAvailable(plasmoidContainer.x, plasmoidContainer.y, plasmoidContainer.width, plasmoidContainer.height, true)
        plasmoidContainer.destroy()
    }

    property QGraphicsWidget applet
    onAppletChanged: {
        applet.appletDestroyed.connect(appletDestroyed)
        applet.parent = plasmoidContainer
        plasmoidContainer.title = applet.name

        appletTimer.running = true
        plasmoidContainer.minimumWidth = Math.max(LayoutManager.cellSize.width, applet.minimumSize.width)
        plasmoidContainer.minimumHeight = Math.max(LayoutManager.cellSize.height, applet.minimumSize.height)
    }

    PlasmaCore.SvgItem {
        svg: configIconsSvg
        elementId: "close"
        width: Math.max(16, plasmoidContainer.titleHeight - 2)
        height: width
        anchors {
            right: plasmoidContainer.contents.right
            bottom: plasmoidContainer.contents.top
            bottomMargin: 4
        }
        MouseArea {
            anchors.fill: parent
            anchors.margins: -6
            onClicked: {
                applet.action("remove").trigger()
            }
        }
    }

    PlasmaCore.SvgItem {
        svg: configIconsSvg
        elementId: "configure"
        width: Math.max(16, plasmoidContainer.titleHeight - 2)
        height: width
        anchors {
            left: plasmoidContainer.contents.left
            bottom: plasmoidContainer.contents.top
            bottomMargin: 4
        }
        MouseArea {
            anchors.fill: parent
            anchors.margins: -6
            onClicked: {
                applet.action("configure").trigger()
            }
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
                plasmoidContainer.imagePath = "widgets/background"
            } else {
                plasmoidContainer.imagePath = "widgets/translucentbackground"
            }
            applet.backgroundHints = "NoBackground"

            applet.x = plasmoidContainer.contents.x
            applet.y = plasmoidContainer.contents.y
            applet.width = plasmoidContainer.contents.width
            applet.height = plasmoidContainer.contents.height
        }
    }
}
