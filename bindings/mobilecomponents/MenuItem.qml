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

Column {
    id: main
    spacing: 5

    PlasmaCore.SvgItem {
        svg: lineSvg
        elementId: "horizontal-line"
        width: entriesColumn.width
        height: lineSvg.elementSize("horizontal-line").height
        visible: main.y > 0
    }

    Loader {
        id: itemLoader
        width: Math.max(item.implicitWidth, main.parent.width)
        height: item.implicitHeight

        //FIXME: the uppercasing should not be necessary, it's ugly
        source: "menuitems/" + operationName.charAt(0).toUpperCase() + operationName.slice(1) + "Item.qml"
        onStatusChanged: {
            //fallback
            if (status == Loader.Error) {
                source = "menuitems/DefaultItem.qml"
            }
        }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                itemLoader.item.run(mouse.x, mouse.y)
                feedbackMessageAnimation.target = main
                feedbackMessageAnimation.running = true
            }
        }
    }


    function run(x, y)
    {
        itemLoader.item.run(x, y)
    }
}
