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

import QtQuick 2.1
import QtGraphicalEffects 1.0
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kquickcontrolsaddons  2.0


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


    Item {
        id: mainPage
        anchors.fill: parent
    }

    Rectangle {
        anchors.fill: parent
        color: "black"
        opacity: 0.6 * (1 - browserFrame.x / root.width)
    }
    MouseArea {
        anchors.fill: parent
        enabled: browserFrame.state == "Open"
        onClicked: browserFrame.state = "Closed"
    }

    Rectangle {
        id: browserFrame
        z: 100
        color: PlasmaCore.ColorScope.backgroundColor
        anchors {
            top: parent.top
            bottom: parent.bottom
        }

        width: {
            if (drawerPage.children.length > 0 && drawerPage.children[0].implicitWidth > 0) {
                return Math.min( parent.width - units.gridUnit, drawerPage.children[0].implicitWidth)
            } else {
                return parent.width - units.gridUnit * 3
            }
        }

        state: "Closed"
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


        LinearGradient {
            width: units.gridUnit/2
            anchors {
                right: parent.left
                top: parent.top
                bottom: parent.bottom
                rightMargin: -1
            }
            start: Qt.point(0, 0)
            end: Qt.point(units.gridUnit, 0)
            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color: "transparent"
                }
                GradientStop {
                    position: 0.7
                    color: Qt.rgba(0, 0, 0, 0.3)
                }
                GradientStop {
                    position: 1.0
                    color: Qt.rgba(0, 0, 0, 0.5)
                }
            }
        }


        MouseEventListener {
            id: mouseEventListener
            anchors {
                fill: parent
                leftMargin: -units.gridUnit
            }

            property int startBrowserFrameX
            property int startMouseScreenX
            property real oldMouseScreenX
            property bool toggle: false
            property bool startDragging: false
            property string startState

            onPressed: {
                startBrowserFrameX = browserFrame.x
                oldMouseScreenX = mouse.screenX
                startMouseScreenX = mouse.screenX
                toggle = (mouse.x < units.gridUnit)
                startDragging = false
                startState = browserFrame.state
                browserFrame.state = "Dragging"
                toggle = mouse.x < units.gridUnit
            }
            onPositionChanged: {
                //mouse over handle and didn't move much
                if (mouse.x > units.gridUnit ||
                    Math.abs(mouse.screenX - startMouseScreenX) > 20) {
                    toggle = false
                }
                if (mouse.x < units.gridUnit ||
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
                if (toggle || Math.abs(browserFrame.x - startBrowserFrameX) > browserFrame.width / 3) {
                    browserFrame.state = startState == "Open" ? "Closed" : "Open"
                } else {
                    browserFrame.state = startState
                }
            }

            Item {
                id: drawerPage
                anchors {
                    fill: parent
                    leftMargin: units.gridUnit * 2
                }
                clip: true
            }
        }

        states: [
            State {
                name: "Open"
                PropertyChanges {
                    target: browserFrame
                    x: root.width - browserFrame.width
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

