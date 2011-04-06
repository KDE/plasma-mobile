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
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.qtextracomponents 4.7

Rectangle {
    property int count: countHint?countHint:Math.min(elementsView.count, 3)
    width: delegateSize*count+10*(count-1)
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
        id: elementsView
        model: elements
        orientation: ListView.Horizontal
        clip: true
        anchors.fill: parent
        snapMode: ListView.SnapOneItem
        /*spacing: 16
        anchors.leftMargin: 8
        anchors.rightMargin: 8*/

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
                wrapMode: Text.WordWrap
                width: Math.min(paintedWidth, 100)
                horizontalAlignment: Text.AlignHCenter
                anchors.top: elementIcon.bottom
                anchors.horizontalCenter: parent.horizontalCenter
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    var args = model.arguments.split(' ')

                    plasmoid.runCommand(command, Array(args))
                }
            }
        }
    }
    PlasmaCore.Svg {
        id: arrowsSvg
        imagePath: "widgets/arrows"
    }

    PlasmaCore.SvgItem {
        anchors.left: parent.left
        anchors.verticalCenter: elementsView.verticalCenter
        width: 22
        height: 22
        svg: arrowsSvg
        elementId: "left-arrow"
        opacity: elementsView.atXBeginning?0.15:1
        Behavior on opacity {
            NumberAnimation {duration: 250}
        }
    }

    PlasmaCore.SvgItem {
        anchors.right: parent.right
        anchors.verticalCenter: elementsView.verticalCenter
        width: 22
        height: 22
        svg: arrowsSvg
        elementId: "right-arrow"
        opacity: elementsView.atXEnd?0.15:1
        Behavior on opacity {
            NumberAnimation {duration: 250}
        }
    }
}
