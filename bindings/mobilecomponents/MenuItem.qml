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


Item {
    id: main
    width: Math.max(itemLoader.item.implicitWidth, parent.width)
    height: itemLoader.item.implicitHeight

    Loader {
        id: itemLoader

        //FIXME: the uppercasing should not be necessary, it's ugly
        source: "menuitems/" + action.charAt(0).toUpperCase() + action.slice(1) + "Item.qml"
        onStatusChanged: {
            //fallback
            if (status == Loader.Error) {
                source = "menuitems/DefaultItem.qml"
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            itemLoader.item.run(mouse.x, mouse.y)
            feedbackMessageText.text = menuItem.text
            feedbackMessageAnimation.running = true
        }
    }

    function run(x, y)
    {
        itemLoader.item.run(x, y)
    }
}
