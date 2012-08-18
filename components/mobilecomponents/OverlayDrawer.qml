/*
 *   Copyright 2012 Marco Martin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Library General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 1.1
import org.kde.plasma.components 0.1 as PlasmaComponents
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.qtextracomponents 0.1


/**Documented API
Inherits:
        Page from org.kde.plasmacomponents

Imports:
        org.kde.plasma.core
        org.kde.plasma.components
        QtQuick 1.1

Description:
        Overlay Drawers are used to expose additional UI elements needed for small secondary tasks for which the main UI elements are not needed. For example in Okular Active, an Overlay Drawer is used to display thumbnails of all pages within a document along with a search field. This is used for the distinct task of navigating to another page.

Properties:
        bool open:
        If true the drawer is open showing the contents of the "drawer" component.

        Item page:
        It's the default property. it's the main content of the drawer page, the part that is always shown

        Item drawer:
        It's the part that can be pulled in and out, will act as a sidebar.
**/
PlasmaComponents.Page {
    id: root
    anchors.fill: parent

    default property alias page: mainPage.data
    property alias drawer: drawerPage.data
    property alias open: browserFrame.open


    MouseEventListener {
        id: mainPage
        property int startMouseScreenX: 0
        property int startMouseScreenY: 0
        onPressed: {
            startMouseScreenX = mouse.screenX
            startMouseScreenY = mouse.screenY
        }
        onReleased: {
            if (Math.abs(mouse.screenX - startMouseScreenX) > 20 ||
                Math.abs(mouse.screenY - startMouseScreenY) > 20) {
                return
            }
            if (browserFrame.state != "Hidden") {
                browserFrame.state = "Hidden"
            } else {
                browserFrame.state = "Closed"
            }
        }
        anchors.fill: parent
    }

    Image {
        id: browserFrame
        z: 100
        source: "image://appbackgrounds/standard"
        fillMode: Image.Tile
        anchors {
            top: parent.top
            bottom: parent.bottom
        }

        width: parent.width - handleGraphics.width
        state: "Hidden"
        onStateChanged: open = (state == "Open" || mouseEventListener.startState == "Open")
        property bool open: false
        onOpenChanged: openChangedTimer.restart()

        Timer {
            id: openChangedTimer
            interval: 0
            onTriggered: {
                if (open) {
                    browserFrame.state = "Open"
                } else {
                    browserFrame.state = "Closed"
                }
            }
        }


        Image {
            source: "image://appbackgrounds/shadow-left"
            fillMode: Image.TileVertically
            anchors {
                right: parent.left
                top: parent.top
                bottom: parent.bottom
                rightMargin: -1
            }
        }
        PlasmaCore.FrameSvgItem {
            id: handleGraphics
            imagePath: "dialogs/background"
            enabledBorders: "LeftBorder|TopBorder|BottomBorder"
            width: handleIcon.width + margins.left + margins.right + 4
            height: handleIcon.width * 1.6 + margins.top + margins.bottom + 4
            anchors {
                right: parent.left
                verticalCenter: parent.verticalCenter
            }

            PlasmaCore.SvgItem {
                id: handleIcon
                svg: PlasmaCore.Svg {imagePath: "toolbar-icons/show"}
                elementId: "show-menu"
                x: parent.margins.left
                y: parent.margins.top
                width: theme.smallMediumIconSize
                height: width
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        MouseEventListener {
            id: mouseEventListener
            anchors {
                top: parent.top
                bottom: parent.bottom
                left: handleGraphics.left
                right: parent.right
            }

            property int startBrowserFrameX
            property real oldMouseScreenX
            property bool toggle: false
            property bool startDragging: false
            property string startState

            onPressed: {
                startBrowserFrameX = browserFrame.x
                oldMouseScreenX = mouse.screenX
                startMouseScreenX = mouse.screenX
                toggle = (mouse.x < handleGraphics.width)
                startDragging = false
                startState = browserFrame.state
                browserFrame.state = "Dragging"
                toggle = mouse.x < handleGraphics.width
            }
            onPositionChanged: {
                //mouse over handle and didn't move much
                if (mouse.x > handleGraphics.width ||
                    Math.abs(mouse.screenX - startMouseScreenX) > 20) {
                    toggle = false
                }
                if (mouse.x < handleGraphics.width ||
                    Math.abs(mouse.screenX - startMouseScreenX) > root.width / 5) {
                    startDragging = true
                }
                if (startDragging) {
                    browserFrame.x = Math.max(root.width - browserFrame.width, browserFrame.x + mouse.screenX - oldMouseScreenX)
                }
                oldMouseScreenX = mouse.screenX
            }
            onReleased: {
                //If one condition for toggle is satisfied toggle, otherwise do an animation that resets the original position
                if (toggle || Math.abs(browserFrame.x - startBrowserFrameX) > root.width / 3) {
                    browserFrame.state = startState == "Open" ? "Closed" : "Open"
                } else {
                    browserFrame.state = startState
                }
            }

            Item {
                id: drawerPage
                anchors {
                    fill: parent
                    leftMargin: handleGraphics.width
                }
                clip: true
            }
        }

        states: [
            State {
                name: "Open"
                PropertyChanges {
                    target: browserFrame
                    x: handleGraphics.width
                }

            },
            State {
                name: "Dragging"
                //workaround for a quirkiness of the state machine
                //if no x binding gets defined in this state x will be set to whatever last x it had last time it was in this state
                PropertyChanges {
                    target: browserFrame
                    x: mouseEventListener.startBrowserFrameX
                }
            },
            State {
                name: "Closed"
                PropertyChanges {
                    target: browserFrame
                    x: root.width
                }
            },
            State {
                name: "Hidden"
                PropertyChanges {
                    target: browserFrame
                    x: root.width + handleGraphics.width
                }
            }
        ]

        transitions: [
            Transition {
                //Exclude Dragging
                to: "Open,Closed,Hidden"
                NumberAnimation {
                    properties: "x"
                    duration: 250
                    easing.type: Easing.InOutQuad
                }
            }
        ]
    }
}

