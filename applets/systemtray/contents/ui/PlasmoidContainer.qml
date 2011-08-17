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
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents

Item {
    id: plasmoidContainer
    width: 24
    anchors.top: tasksRow.top
    anchors.bottom: tasksRow.bottom
    opacity: watcher.status != MobileComponents.AppletStatusWatcher.PassiveStatus?1:0

    Behavior on opacity {
        NumberAnimation {
            duration: 300
            easing.type: Easing.InOutQuad
        }
    }

    property QGraphicsWidget applet
    onAppletChanged: {
        print(plasmoidContainer.applet)
        plasmoidContainer.applet.parent = plasmoidContainer
        plasmoidContainer.applet.height = plasmoidContainer.height
        plasmoidContainer.applet.x=0
        plasmoidContainer.applet.y=0
        watcher.plasmoid = plasmoidContainer.applet
    }

    MobileComponents.AppletStatusWatcher {
        id: watcher
    }

    onHeightChanged: {
        plasmoidContainer.applet.height = height
        if (plasmoidContainer.applet.minimumSize.width>0) {
            plasmoidContainer.applet.width = plasmoidContainer.applet.preferredSize.width
        }
        plasmoidContainer.width = plasmoidContainer.applet.width
    }
}