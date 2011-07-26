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
        plasmoidContainer.destroy()
    }

    property QGraphicsWidget applet
    onAppletChanged: {
        applet.appletDestroyed.connect(appletDestroyed)
        applet.parent = plasmoidContainer
        plasmoidContainer.title = applet.name

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
