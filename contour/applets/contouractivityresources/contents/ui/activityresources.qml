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

import Qt 4.7
import org.kde.qtextracomponents 4.7
import org.kde.plasma.graphicswidgets 0.1 as PlasmaWidgets
import org.kde.plasma.core 0.1 as PlasmaCore

Item {
    width: 200
    height: 200
    property int delegateSize: 128

    Flow {
        anchors.fill: parent
        spacing: 10
        Repeater {
            model: ResourcesModel {}
            Rectangle {
                width: delegateSize*2
                height: delegateSize
                color: Qt.rgba(1,1,1,0.3)
                radius: 5
                border.color: "white"
                border.width: 5
                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: childrenRect.height
                    radius: 5
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: name
                    }
                }

                ListView {
                    model: elements
                    orientation: ListView.Horizontal
                    clip: true
                    anchors.fill: parent

                    delegate: Item {
                        width: delegateSize
                        height: delegateSize

                        QIconItem {
                            id: elementIcon
                            anchors.centerIn: parent
                            width: 64
                            height: 64
                            icon: QIcon(model.icon)
                        }
                        Text {
                            id: nameText
                            text: name
                            anchors.top: elementIcon.bottom
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                }
            }
        }
    }
}
