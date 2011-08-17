/*
 *   Copyright 2010 Marco Martin <notmart@gmail.com>
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

Item {
    id: listItem
    property alias padding: paddingRectangle
    signal clicked;
    width: parent.width
    height: childrenRect.height+4
    property int implicitHeight


    PlasmaCore.FrameSvgItem {
        id : background
        imagePath: "widgets/listitem"
        prefix: "normal"

        anchors.fill: parent


        MouseArea {
            id: itemMouse
            anchors.fill: background
            onClicked: listItem.clicked()
        }
    }

    Item {
        id: paddingRectangle
        anchors {
            fill: background
            leftMargin: background.margins.left
            topMargin: background.margins.top
            rightMargin: background.margins.right
            bottomMargin: background.margins.bottom
        }
    }
}
