/***************************************************************************
 *   Copyright 2011 Artur Duque de Souza <asouza@kde.org>                  *
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

import QtQuick 1.0
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.qtextracomponents 0.1


Rectangle {
    id: lockScreen
    width: 800
    height: 600
    color: Qt.rgba(0, 0, 0, 0.8)

    PlasmaCore.Theme {
        id: theme
    }

    Behavior on opacity {
        NumberAnimation {duration: 250}
    }

    Item {
        id: lockArea
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 120
    }

    Item {
        id: unlockArea
        anchors.top: lockArea.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right


        Text {
            id: unlockText
            text: i18n("Drag here to unlock")
            color: "white"
            anchors.centerIn: parent
            font.pixelSize: 36
            font.family: theme.font.family
            font.bold: theme.font.bold
            font.capitalization: theme.font.capitalization
            font.italic: theme.font.italic
            font.weight: theme.font.weight
            font.underline: theme.font.underline
            font.strikeout: theme.font.strikeOut
            font.wordSpacing: theme.font.wordSpacing
            opacity: 0

            Behavior on opacity {
                NumberAnimation { duration: 200 }
            }
        }

    }

    Rectangle {
        id: locker
        anchors.bottom: lockArea.bottom
        anchors.topMargin: 10
        anchors.right: lockArea.right
        anchors.rightMargin: 20
        color: theme.backgroundColor
        opacity: 0.8
        radius: 10
        width: 62
        height: 62
        state: "default"

        Rectangle {
            id: halo
            anchors.fill: locker
            radius: 10
            color: theme.textColor
            opacity: 0
        }

        QIconItem {
            id: lockerImage
            width: 48
            height: 48
            anchors.centerIn: parent
            icon: QIcon("object-locked")
        }

        MouseArea {
            anchors.fill: locker
            drag.target: locker
            onPressed: {
                locker.state = "drag"
            }

            onReleased: {
                var pos = (locker.x > unlockArea.x && locker.y > unlockArea.y);
                var size = (locker.x < unlockArea.width && locker.y < unlockArea.height);

                if (pos && size) {
                    lockScreen.state = "unlock"
                }

                locker.state = "default"
            }
        }

        states: [
            State {
                name: "drag"
                PropertyChanges {
                    target: locker
                    anchors.bottom: undefined
                    anchors.right: undefined
                }
                PropertyChanges {
                    target: lockerImage
                    icon: QIcon("object-unlocked")
                }
                PropertyChanges {
                    target: unlockText
                    opacity: 0.6
                }
            },
            State {
                name: "default"
                PropertyChanges {
                    target: locker
                    anchors.bottom: lockArea.bottom
                    anchors.right: lockArea.right
                }
                PropertyChanges {
                    target: lockerImage
                    icon: QIcon("object-locked")
                }
                PropertyChanges {
                    target: unlockText
                    opacity: 0
                }
            }
        ]
    }

    states: [
        State {
            name: "unlock"
            PropertyChanges {
                target: lockScreen
                opacity: 0
            }
        }
    ]
}

