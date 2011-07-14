/*
 *   Copyright 2011 Sebastian Kügler <sebas@kde.org>
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
import org.kde.qtextracomponents 0.1

Item {
    property alias icon: iconItem.icon
    signal clicked
    signal pressAndHold
    id: iconButton
    width: 64
    height: 64

    QIconItem {
        id: iconItem
        anchors.fill: parent

        MouseArea {
            anchors.fill: parent
            onClicked: iconButton.clicked()
            onPressAndHold: iconButton.pressAndHold()
            onPressed: iconButton.state = "Pressed"
            onReleased: iconButton.state = "Normal"
        }

    }

    states: [
        State {
            name: "Normal"
            PropertyChanges { target: iconItem; scale: 1.0}
        },
        State {
            name: "Pressed"
            PropertyChanges { target: iconItem; scale: 0.9}
        }
    ]

    transitions: [
        Transition {
            NumberAnimation { properties: "scale"; duration: 50 }
        }
    ]

}
