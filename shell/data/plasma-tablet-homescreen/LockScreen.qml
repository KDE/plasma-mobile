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


Rectangle {
    id: lockScreen
    width: 800
    height: 600
    color: Qt.rgba(0, 0, 0, 0.8)

    signal unlocked();

    Rectangle {
        id: lockArea
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 60
        color: Qt.rgba(0, 0, 0, 0.8)
    }

    Rectangle {
        id: unlockArea
        anchors.top: lockArea.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        color: Qt.rgba(0, 0, 0, 0.8)
        border.color: Qt.rgba(0, 0, 0, 0.8)
        border.width: 0

        property bool unlock: (locker.x > unlockArea.x && locker.y > unlockArea.y) &&
            (locker.x < unlockArea.width && locker.y < unlockArea.height);

        Text {
            id: unlockText
            text: "Drag here to unlock"
            color: "white"
            anchors.centerIn: parent
            font.pixelSize: 36
            opacity: 0
            states: [
                State {
                    name: "active"
                    when: (locker.state == "unlock")
                    PropertyChanges {
                        target: unlockText
                        opacity: 1
                    }
                }
            ]

            Behavior on opacity {
                NumberAnimation { duration: 500 }
            }
        }

        states: [
            State {
                name: "active"
                when: (locker.state == "unlock") && (!unlockArea.unlock)
                PropertyChanges {
                    target: unlockArea
                    border.color: "#0a4193"
                    border.width: 5
                }
            },
            State {
                name: "unlock"
                when: (locker.state == "unlock") && (unlockArea.unlock)
                PropertyChanges {
                    target: unlockArea
                    color: "#0a4193"
                    opacity: 0.7
                    border.color: "#0a4193"
                    border.width: 15
                }
            }
        ]
    }

    Rectangle {
        id: lockerBackground
        anchors.fill: locker
        color: Qt.rgba(0, 0, 0, 0.8)
        radius: 10

        states: [
            State {
                name: "active"
                when: locker.state == "unlock"
                PropertyChanges {
                    target: lockerBackground
                    color: "#0a4193"
                }
            }
        ]
    }

    Image {
        id: locker
        source: "images/lock.png"
        anchors.top: lockArea.top
        anchors.topMargin: 5
        anchors.right: lockArea.right
        anchors.rightMargin: 20

        states: [
            State {
                name: "unlock"
                PropertyChanges {
                    target: locker
                    source: "images/unlock.png"
                    anchors.right: undefined
                    anchors.top: undefined
                }
            }
        ]
    }

    MouseArea {
        // this is the item that will properly lock
        // the screen as it will grab all the events
        anchors.fill: parent
    }

    MouseArea {
        anchors.fill: locker
        drag.target: locker
        onPressed: {
            locker.state = "unlock"
        }

        onReleased: {
            var pos = (locker.x > unlockArea.x && locker.y > unlockArea.y);
            var size = (locker.x < unlockArea.width && locker.y < unlockArea.height);

            if (pos && size) {
                unlocked();
            }

            // give some time to restore default state?
            locker.state = "default"
        }
    }
}

