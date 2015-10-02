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
Item {
    id: root
    anchors.fill: parent
    visible: true

    default property alias page: mainPage.data
    property alias drawer: drawerPage.data
    property alias open: browserFrame.open


    Item {
        id: mainPage
        anchors.fill: parent
        onChildrenChanged: mainPage.children[0].anchors.fill = mainPage
    }

    Rectangle {
        anchors.fill: parent
        color: "black"
        opacity: 0.6 * (1 - browserFrame.x / root.width)
    }

    MouseArea {
        anchors {
            right: parent.right
            top: parent.top
            bottom: parent.bottom
        }
        z: 99
        width: units.smallSpacing
        onPressed: {
            mouseEventListener.managePressed(mouse)
        }
        onPositionChanged: {
            mouseEventListener.positionChanged(mouse)
        }
        onReleased: {
            var pos = mapToItem(mouseEventListener, mouse.x, mouse.y);
            mouseEventListener.released(mouse)
        }
    }
    MouseArea {
        id: mouseEventListener
        anchors.fill: parent
        drag.filterChildren: true
        property int startBrowserFrameX
        property int startMouseX
        property real oldMouseX
        property bool startDragging: false
        property string startState
        enabled: browserFrame.state != "Closed"

        onPressed: managePressed(mouse)
        function managePressed(mouse) {
            if (drawerPage.children.length == 0) {
                mouse.accepted = false;
                return;
            }

            mouse.accepted = true;
            startBrowserFrameX = browserFrame.x;
            oldMouseX = startMouseX = mouse.x;
            startDragging = false;
            startState = browserFrame.state;
            browserFrame.state = "Dragging";
            browserFrame.x = startBrowserFrameX;
        }

        onPositionChanged: {
            if (drawerPage.children.length == 0) {
                mouse.accepted = false;
                return;
            }

            if (mouse.x < units.gridUnit ||
                Math.abs(mouse.x - startMouseX) > root.width / 5) {
                startDragging = true;
            }
            if (startDragging) {
                browserFrame.x = Math.max(root.width - browserFrame.width, browserFrame.x + mouse.x - oldMouseX);
            }
            oldMouseX = mouse.x;
        }

        onReleased: {
            if (drawerPage.children.length == 0) {
                mouse.accepted = false;
                return;
            }

            if (mouse.x > width - units.gridUnit) {
                browserFrame.state = "Closed";
            } else if (browserFrame.x - startBrowserFrameX > browserFrame.width / 3) {
                browserFrame.state = "Closed";
            } else if (startBrowserFrameX - browserFrame.x > browserFrame.width / 3) {
                browserFrame.state = "Open";
            } else {
                browserFrame.state = startState
            }
        }
        onCanceled: {
            if (oldMouseX > width - units.gridUnit) {
                browserFrame.state = "Closed";
            } else if (Math.abs(browserFrame.x - startBrowserFrameX) > browserFrame.width / 3) {
                browserFrame.state = startState == "Open" ? "Closed" : "Open";
            }
        }
        onClicked: {
            if (mouse.x < browserFrame.x) {
                browserFrame.state = startState == "Open" ? "Closed" : "Open";
            }
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
            onStateChanged: open = (state != "Closed")
            property bool open: false
            onOpenChanged: {
                if (drawerPage.children.length == 0) {
                    return;
                }

                if (open) {
                    browserFrame.state = "Open";
                } else {
                    browserFrame.state = "Closed";
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
                end: Qt.point(units.gridUnit/2, 0)
                gradient: Gradient {
                    GradientStop {
                        position: 0.0
                        color: "transparent"
                    }
                    GradientStop {
                        position: 0.7
                        color: Qt.rgba(0, 0, 0, 0.15)
                    }
                    GradientStop {
                        position: 1.0
                        color: Qt.rgba(0, 0, 0, 0.3)
                    }
                }
            }


            MouseArea {
                id: drawerPage
                anchors {
                    fill: parent
                    //leftMargin: units.gridUnit
                }
                clip: true
                onChildrenChanged: drawerPage.children[0].anchors.fill = drawerPage
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
                        duration: units.longDuration
                        easing.type: Easing.InOutQuad
                    }
                }
            ]
        }
    }
}

