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


Rectangle {
    id: lockScreen
    width: 800
    height: 600
    color: Qt.rgba(0, 0, 0, 0.8)

    signal unlocked();

    PlasmaCore.Theme {
        id: theme
    }

    Behavior on opacity {
        NumberAnimation {duration: 250}
    }

    Rectangle {
        id: lockArea
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 80
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
            color: theme.textColor
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
                NumberAnimation { duration: 200 }
            }
        }

        states: [
            State {
                name: "active"
                when: (locker.state == "unlock") && (!unlockArea.unlock)
                PropertyChanges {
                    target: unlockArea
                    border.color: theme.textColor
                    border.width: 5
                }
            },
            State {
                name: "unlock"
                when: (locker.state == "unlock") && (unlockArea.unlock)
                PropertyChanges {
                    target: unlockArea
                    color: theme.textColor
                    opacity: 0.7
                    border.color: theme.textColor
                    border.width: 15
                }
            }
        ]
    }

    Rectangle {
        id: locker
        anchors.top: lockArea.top
        anchors.topMargin: 10
        anchors.right: lockArea.right
        anchors.rightMargin: 20
        color: theme.backgroundColor
        opacity: 0.8
        radius: 10
        width: 62
        height: 62

        Rectangle {
            id: halo
            anchors.fill: locker
            radius: 10
            color: theme.textColor
            opacity: 0

            Timer {
                id: haloTimer
                // 2 minutes to turn off the halo
                // ### TODO: take this from config file
                interval: 2 * 60 * 1000
                running: true
                onTriggered: {
                    halo.visible = false
                }
            }

            SequentialAnimation on opacity {
                running: (locker.state != "unlock")
                loops: Animation.Infinite
                NumberAnimation {
                    to: 1
                    duration: 1000
                    easing.type: Easing.InOutQuad
                }
                NumberAnimation {
                    to: 0
                    duration: 1000
                    easing.type: Easing.InOutQuad
                }
            }
        }


        Image {
            id: lockerImage
            width: 52
            height: 52
            anchors.centerIn: parent
            source: "images/lock.png"
        }

        states: [
            State {
                name: "unlock"
                PropertyChanges {
                    target: locker
                    anchors.right: undefined
                    anchors.top: undefined
                    color: theme.textColor
                }
                PropertyChanges {
                    target: lockerImage
                    source: "images/unlock.png"
                }
            }
        ]
    }

    MouseArea {
        // this is the item that will properly lock
        // the screen as it will grab all the events
        anchors.fill: parent
        onPressed: {
            halo.visible = true;
            haloTimer.running = true;
        }
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

