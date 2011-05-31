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
import org.kde.qtextracomponents 0.1

Item {
    id: resourceDelegate
    width: delegateSize
    height: delegateSize
    property alias text: nameText.text
    property string resourceType: itemGroup.category
    property string icon
    function setDarkenVisible(visible)
    {
        if (visible) {
            itemGroup.z = 900
            darkenRect.opacity = 1
        } else {
            elementsView.currentIndex = -1
            itemGroup.z = 0
            darkenRect.opacity = 0
        }
    }

    QIconItem {
        id: elementIcon
        anchors.centerIn: parent
        width: 64
        height: 64
        icon: QIcon(resourceDelegate.icon)
    }
    Rectangle {
        radius: 5
        opacity: 0.75
        color: "white"
        anchors.top: elementIcon.bottom

        anchors.horizontalCenter: parent.horizontalCenter
        width: nameText.paintedWidth
        height: nameText.paintedHeight
        anchors.margins: 8
        Text {
            id: nameText
            text: model.name
            wrapMode: Text.NoWrap
            elide: Text.ElideRight
            width: 120
        }
    }
    Slider {
        
    }
    /*
    MouseArea {
        anchors.fill: parent
        onClicked: {
            var args = model.arguments.split(' ')

            plasmoid.runCommand(command, Array(args))
        }

        onPressAndHold: {
            contextMenu.delegate = resourceDelegate
            contextMenu.resourceType = itemGroup.category
 
            contextMenu.state = "show"
            //event.accepted = true
            elementsView.interactive = false
            setDarkenVisible(true)
            elementsView.currentIndex = index
        }

        onPositionChanged: {
            contextMenu.highlightItem(mouse.x, mouse.y)
        }

        onReleased: {
            elementsView.interactive = true
            contextMenu.activateItem(mouse.x, mouse.y)
        }
    }
    */
}
