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
    property int visibleDrawerWidth: width - browserFrame.width

    Component.onCompleted: {
        mainPage.width = browserFrame.width - handleGraphics.width
    }


    Image {
        id: browserFrame
        //visible: mainPage.children.length > 0
        z: 100
        source: "image://appbackgrounds/standard"
        fillMode: Image.Tile
        anchors {
            top: parent.top
            bottom: parent.bottom
        }
        x: mainPage.children.length > 0 && mainPage.children[0].visible ? 0 : - width
        width: handleGraphics.x + handleGraphics.width
        clip: true

        function handlePosition()
        {
            return sidebar.open ? root.width - sidebar.width - handleGraphics.width : root.width - handleGraphics.width
        }

        Behavior on x {
            NumberAnimation {
                duration: 250
                easing.type: Easing.InOutQuad
            }
        }

        Item {
            id: mainPage
            anchors {
                left: parent.left
                top: parent.top
                bottom: parent.bottom
            }
        }

        PlasmaCore.FrameSvgItem {
            id: handleGraphics
            imagePath: "dialogs/background"
            enabledBorders: "LeftBorder|TopBorder|BottomBorder"
            width: handleIcon.width + margins.left + margins.right + 4
            height: handleIcon.width * 1.6 + margins.top + margins.bottom + 4
            anchors.verticalCenter: parent.verticalCenter

            Component.onCompleted: {
                handleGraphics.x = browserFrame.handlePosition()
            }

            //TODO: an icon
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
        MouseArea {
            anchors {
                top: parent.top
                bottom: parent.bottom
                left: handleGraphics.left
                right: handleGraphics.right
            }
            drag {
                target: handleGraphics
                axis: Drag.XAxis
                //-50, an overshoot to make it look smooter
                minimumX: root.width - sidebar.width - handleGraphics.width - 50
                maximumX: root.width - handleGraphics.width
            }
            property int startX
            property bool toggle: true
            onPressed: {
                startX = handleGraphics.x
                toggle = true
            }
            onPositionChanged: {
                if (Math.abs(handleGraphics.x - startX) > 20) {
                    toggle = false
                }
            }
            onReleased: {
                if (toggle) {
                    sidebar.open = !sidebar.open
                } else {
                    sidebar.open = (browserFrame.width < root.width -sidebar.width/2)
                }
                sidebarSlideAnimation.to = browserFrame.handlePosition()
                sidebarSlideAnimation.running = true
            }
        }
        //FIXME: use a state machine
        SequentialAnimation {
            id: sidebarSlideAnimation
            property alias to: actualSlideAnimation.to

            NumberAnimation {
                id: actualSlideAnimation
                target: handleGraphics
                properties: "x"
                duration: 250
                easing.type: Easing.InOutQuad
            }
            ScriptAction {
                script: mainPage.width = browserFrame.width - handleGraphics.width
            }
        }
    }
    Image {
        source: "image://appbackgrounds/shadow-right"
        fillMode: Image.TileVertically
        anchors {
            left: browserFrame.right
            top: browserFrame.top
            bottom: browserFrame.bottom
            leftMargin: -1
        }
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
            handleGraphics.x = browserFrame.handlePosition()
            mainPage.width = browserFrame.width - handleGraphics.width
        }
        x: parent.width - width

        anchors {
            top: parent.top
            bottom: parent.bottom
        }

        Item {
            id: panelPage
            anchors.fill: parent
            clip: true
        }
    }

    Image {
        source: "image://appbackgrounds/shadow-bottom"
        fillMode: Image.TileHorizontally
        opacity: 0.8
        anchors {
            left: parent.left
            top: toolBar.bottom
            right: parent.right
            topMargin: -2
        }
    }
}

