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

/**Documented API
Inherits:
        Page from org.kde.plasmacomponents

Imports:
        org.kde.plasma.core
        org.kde.plasma.components
        QtQuick 1.1

Description:
        Split Drawers are used to expose additional UI elements which are optional and can be used in conjunction with the main UI elements. For example the Resource Browser uses a Split Drawer to select different kinds of filters for the main view.

Properties:
        bool open:
        If true the drawer is open showing the contents of the "drawer" component.

        Item page:
        It's the default property. it's the main content of the drawer page, the part that is always shown

        Item drawer:
        It's the part that can be pulled in and out, will act as a sidebar.

        int visibleDrawerWidth: the width of the visible portion of the drawer: it updates while dragging or animating
**/
PlasmaComponents.Page {
    id: root
    anchors {
        fill: parent
    }

    default property alias page: mainPage.data
    property alias drawer: panelPage.data
    property alias open: sidebar.open
    property int visibleDrawerWidth: browserFrame.x

    Component.onCompleted: {
        mainPage.width = browserFrame.width
    }

    MouseArea {
        id: mouseEventListener
        z: 200
        drag.filterChildren: true
        //drag.target: browserFrame
        property int startMouseX
        property int oldMouseX
        property int startBrowserFrameX

        anchors.fill: parent

        onPressed: {
            if ((browserFrame.state == "Closed" && mouse.x > units.gridUnit) ||
                mouse.x < browserFrame.x) {
                mouse.accepted = false;
                return;
            }

            startBrowserFrameX = browserFrame.x;
            oldMouseX = startMouseX = mouse.x;
            browserFrame.state = "Dragging";
            browserFrame.x = startBrowserFrameX;
        }

        onPositionChanged: {
            browserFrame.x = Math.max(0, browserFrame.x + mouse.x - oldMouseX);
            oldMouseX = mouse.x;
        }

        onReleased: {
            if (browserFrame.x < sidebar.width / 2) {
                browserFrame.state = "Closed";
            } else {
                browserFrame.state = "Open";
            }
        }
    }

    Rectangle {
        id: browserFrame
        z: 100
        color: PlasmaCore.ColorScope.backgroundColor
        state: "Closed"
        onStateChanged: sidebar.open = (state != "Closed")

        anchors {
            top: parent.top
            bottom: parent.bottom
        }
        width: root.width;

        Item {
            id: mainPage
            onChildrenChanged: mainPage.children[0].anchors.fill = mainPage

            anchors.fill: parent
        }

        Rectangle {
            anchors.fill: parent
            color: "black"
            opacity: 0.6 * (browserFrame.x / sidebar.width)
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

        states: [
            State {
                name: "Open"
                PropertyChanges {
                    target: browserFrame
                    x: sidebar.width
                }

            },
            State {
                name: "Dragging"
                PropertyChanges {
                    target: browserFrame
                    x: mouseEventListener.startBrowserFrameX
                }
            },
            State {
                name: "Closed"
                PropertyChanges {
                    target: browserFrame
                    x: 0
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


    Item {
        id: sidebar

        property bool open: false
        onOpenChanged: {
            if (width == 0) {
                return
            }
            sidebarSlideAnimation.to = browserFrame.handlePosition()
            sidebarSlideAnimation.running = true
        }

        width: parent.width/4
        onWidthChanged: {
            //handleGraphics.x = browserFrame.handlePosition()
            //mainPage.width = browserFrame.width - handleGraphics.width
        }

        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
        }

        Item {
            id: panelPage
            anchors.fill: parent
            clip: false
        }
    }
}

