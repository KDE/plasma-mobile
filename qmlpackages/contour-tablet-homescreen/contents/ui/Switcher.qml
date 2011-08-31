/***************************************************************************
 *   Copyright 2010 Alexis Menard <menard@kde.org>                         *
 *   Copyright 2010 Artur Duque de Souza <asouza@kde.org>                  *
 *   Copyright 2010 Marco Martin <mart@kde.org>                            *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/

import Qt 4.7
import org.kde.plasma.core 0.1 as PlasmaCore

PlasmaCore.FrameSvgItem {
    id: main
    imagePath: "widgets/background"
    enabledBorders: "TopBorder"
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    height: 32 + margins.top

    property int current: 0
    onCurrentChanged: {
        if (current >= 0) {
            areasBarDragger.x = current*parent.width
        }
    }

    Rectangle {
        id: areasBarDragger
        color: Qt.rgba(0,0,0,0.5)
        x: 0
        y: areasBar.y
        width: parent.width/2
        height: areasBar.height

        onXChanged: {
            mainContainments.x = -parent.width*(x/draggerMouseArea.drag.maximumX)
        }
    }

    Row {
        id: areasBar
        anchors.fill: parent
        anchors.topMargin: parent.margins.top

        Text {
            text: "Activity browser"
            color: theme.textColor
            horizontalAlignment: Text.AlignHCenter
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width/2
        }
        Text {
            text: "Activity selector"
            color: theme.textColor
            horizontalAlignment: Text.AlignHCenter
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width/2
        }

        MouseArea {
            id: draggerMouseArea
            anchors.fill: areasBar
            drag.target: areasBarDragger
            drag.axis: Drag.XAxis
            drag.minimumX: 0
            drag.maximumX: areasBar.width - areasBarDragger.width
            onPressed: {
                current = -1
            }
            onReleased: {
                areasBarDragger.x = areasBarDragger.width * Math.round(areasBarDragger.x/areasBarDragger.width)
            }
            onClicked: {
                areasBarDragger.x = areasBarDragger.width * Math.floor(mouse.x/areasBarDragger.width)
            }
        }
    }
}
