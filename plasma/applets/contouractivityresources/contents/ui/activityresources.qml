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
import org.kde.qtextracomponents 0.1
import org.kde.plasma.graphicswidgets 0.1 as PlasmaWidgets
import org.kde.plasma.core 0.1 as PlasmaCore

Item {
    id: main
    width: 200
    height: 200
    property int delegateSize: 128

    ResourcesModel {
       id: resourceModels
    }

    Row {
        id: slcRow
        height: 32
        y: 48
        spacing: 5
        anchors.right: parent.right
        property Item delegate
        opacity: delegate==undefined?0.5:1
        QIconItem {
            width: height
            anchors {
                top: parent.top
                bottom: parent.bottom
            }
            icon: QIcon("system-users")
            MouseArea {
                anchors.fill: parent
                onPressed: {
                    contextMenu.delegate = slcRow.delegate
                    contextMenu.resourceType = slcRow.delegate.resourceType
                    contextMenu.positionMenu(parent)
                    contextMenu.state = "shown"
                }
            }
        }
        QIconItem {
            width: height
            anchors {
                top: parent.top
                bottom: parent.bottom
            }
            icon: QIcon("emblem-favorite")
            MouseArea {
                anchors.fill: parent
                onPressed: {
                    contextMenu.delegate = slcRow.delegate
                    contextMenu.resourceType = slcRow.delegate.resourceType
                    contextMenu.positionMenu(parent)
                    contextMenu.state = "shown"
                }
            }
        }
        QIconItem {
            width: height
            anchors {
                top: parent.top
                bottom: parent.bottom
            }
            icon: QIcon("network-connect")
            MouseArea {
                anchors.fill: parent
                onPressed: {
                    contextMenu.delegate = slcRow.delegate
                    contextMenu.resourceType = slcRow.delegate.resourceType
                    contextMenu.positionMenu(parent)
                    contextMenu.state = "shown"
                }
            }
        }
    }

    Rectangle {
        x: 32
        y: 48
        height: childrenRect.height
        width: childrenRect.width + 20
        color: "white"
        radius: 10
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: plasmoid.activityName
            font.pixelSize: 25
        }
    }

    Flow {
        id: categoriesFlow
        anchors.centerIn: parent
        width: parent.width - 128
        height: childrenRect.height

        spacing: 10
        Repeater {
            model: resourceModels.model(plasmoid.activityName)
            CategoryDelegate {
                
            }
        }
    }

    ContextMenu {
        id: contextMenu
    }
}
