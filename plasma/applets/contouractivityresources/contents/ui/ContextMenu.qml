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
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents

Item {
    id: contextMenu
    anchors.fill: parent

    state: "hidden"

    onStateChanged: {
        if (state == "hidden") {
            delegate.setDarkenVisible(false)
        }
    }

    function activateItem(x, y)
    {
        menuObject.activateItem(x, y)
    }

    function highlightItem(x, y)
    {
        menuObject.highlightItem(x ,y)
    }

    MouseArea {
        anchors.fill:parent
        onClicked: contextMenu.state = "hidden"
    }

    property string resourceType
    property string source
    property string resourceUrl

    property Item delegate
    onDelegateChanged: {
        positionMenu()
        highlightFrame.opacity = 0
    }


    function positionMenu(delegate)
    {
        var menuPos = delegate.mapToItem(parent, delegate.width/2-menuObject.width/2, delegate.height)

        if (menuPos.y > contextMenu.height/2) {
            menuPos = delegate.mapToItem(parent, delegate.width/2-menuObject.width/2, -menuObject.height)
            menuObject.positionState = "top"
        } else {
            menuObject.positionState = "bottom"
        }

        if (menuPos.x+menuObject.width > contextMenu.width) {
            menuPos.x = contextMenu.width - menuObject.width
        }

        menuObject.x = menuPos.x
        menuObject.y = menuPos.y
    }

    ActionsModel {
        id: actionsModel
    }

    PlasmaCore.Svg {
        id: lineSvg
        imagePath: "widgets/line"
    }

    PlasmaCore.Svg {
        id: tipSvg
        imagePath: "dialogs/background"
    }

    Menu {
        id: menuObject
    }

    states: [
        State {
            name: "show"
            PropertyChanges {
                target: contextMenu
                opacity: 1
            }
            PropertyChanges {
                target: menuObject
                scale: 1
            }
        },
        State {
            name: "hidden"
            PropertyChanges {
                target: contextMenu
                opacity: 0
            }
            PropertyChanges {
                target: menuObject
                scale: 0
            }
        }
    ]

    transitions: [
        Transition {
            from: "show"
            to: "hidden"
            ParallelAnimation {
                NumberAnimation {
                    targets: contextMenu
                    properties: "opacity"
                    duration: 250
                    easing.type: "InOutCubic"
                }
                NumberAnimation {
                    targets: menuObject
                    properties: "scale"
                    duration: 250
                    easing.type: "InOutCubic"
                }
            }
        },
        Transition {
            from: "hidden"
            to: "show"
            ParallelAnimation {
                NumberAnimation {
                    targets: contextMenu
                    properties: "opacity"
                    duration: 250
                    easing.type: "InOutCubic"
                }
                NumberAnimation {
                    targets: menuObject
                    properties: "scale"
                    duration: 250
                    easing.type: "InOutCubic"
                }
            }
        }
    ]

    PlasmaCore.FrameSvgItem {
        id: feedbackMessage
        imagePath: "dialogs/background"
        width: feedbackMessageText.width + margins.left + margins.right
        height: feedbackMessageText.height + margins.top + margins.bottom
        anchors.centerIn: parent
        Text {
            id: feedbackMessageText
            x: feedbackMessage.margins.left
            y: feedbackMessage.margins.top
            font.bold: true
            font.pixelSize: 20
        }
        scale: 0
    }
    SequentialAnimation {
        id: feedbackMessageAnimation
        NumberAnimation {
            target: feedbackMessage
            properties: "scale"
            to: 1
            duration: 300
        }
        PauseAnimation {
            duration: 500
        }
        NumberAnimation {
            target: feedbackMessage
            properties: "scale"
            to: 0
            duration: 300
        }
        ScriptAction {
            script: contextMenu.state = "hidden"
        }
    }
}
