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
        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
        height: 120
    }

    Item {
        id: unlockArea
        anchors {
            top: parent.top
            bottom: lockArea.top
            left: parent.left
            right: parent.right
        }


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


    Image {
        id: lockerImage
        width: 64
        height: 64
        source: homeScreenPackage.filePath("images", "unlock-normal.png")
        state: "default"

        anchors {
            bottom: lockArea.bottom
            topMargin: 10
            horizontalCenter: lockArea.horizontalCenter
        }

        MouseArea {
            anchors.fill: parent
            drag.target: parent
            onPressed: {
                lockerImage.state = "drag"
            }

            onReleased: {
                var pos = (lockerImage.x > unlockArea.x && lockerImage.y > unlockArea.y);
                var size = (lockerImage.x < unlockArea.width && lockerImage.y < unlockArea.height);

                if (pos && size) {
                    lockScreen.state = "unlock"
                }

                lockerImage.state = "default"
            }
        }

        states: [
            State {
                name: "drag"
                PropertyChanges {
                    target: lockerImage
                    anchors.bottom: undefined
                    anchors.horizontalCenter: undefined
                    source: homeScreenPackage.filePath("images", "unlock-pressed.png")
                }
                PropertyChanges {
                    target: unlockText
                    opacity: 0.6
                }
            },
            State {
                name: "default"
                PropertyChanges {
                    target: lockerImage
                    anchors.bottom: lockArea.bottom
                    anchors.horizontalCenter: lockArea.horizontalCenter
                    source: homeScreenPackage.filePath("images", "unlock-normal.png")
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

