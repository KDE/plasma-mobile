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

PlasmaCore.SvgItem {
    id: button
    width: actionSize
    height: actionSize
    svg: iconsSvg
    elementId: "move"
    z: applet.z + 1


    MouseArea {
        anchors.fill: parent
        anchors.leftMargin: -10
        anchors.topMargin: -10
        anchors.rightMargin: -10
        anchors.bottomMargin: -10

        drag.target: plasmoidContainer
        drag.minimumX: 0
        drag.maximumX: mainRow.width
        drag.minimumY: 0
        drag.maximumY: 0

        onPressed: {
            plasmoidContainer.z = 2000
            var index = Math.round(plasmoidContainer.mapToItem(appletsRow, 0, 0).x/(main.width/appletColumns))
            spacer.visible = true
            appletsRow.remove(plasmoidContainer)
            appletsRow.insertAt(spacer, index)
        }

        onReleased: {
            plasmoidContainer.z = 0
            var index = Math.round(plasmoidContainer.mapToItem(appletsRow, 0, 0).x/(main.width/appletColumns))
            appletsRow.insertAt(plasmoidContainer, index)
            appletsRow.remove(spacer)
            spacer.visible = false
        }

        onPositionChanged: {
            var index = Math.round(plasmoidContainer.mapToItem(appletsRow, 0, 0).x/(main.width/appletColumns))

            appletsRow.insertAt(spacer, index)
        }

    }
}
