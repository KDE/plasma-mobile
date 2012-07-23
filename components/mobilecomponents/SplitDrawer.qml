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
import org.kde.metadatamodels 0.1 as MetadataModels
import org.kde.plasma.components 0.1 as PlasmaComponents
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents
import org.kde.draganddrop 1.0
import org.kde.qtextracomponents 0.1


PlasmaComponents.Page {
    id: root
    anchors {
        fill: parent
    }

    default property alias page: mainPage.data
    property alias panel: panelPage.data

    Image {
        id: browserFrame
        z: 100
        source: "image://appbackgrounds/standard"
        fillMode: Image.Tile
        anchors {
            top: parent.top
            bottom: parent.bottom
        }
        width: parent.width
        x: 0

        Item {
            id: mainPage
            anchors {
                fill: parent
                rightMargin: handleGraphics.width
            }
        }

        Image {
            source: "image://appbackgrounds/shadow-right"
            fillMode: Image.TileVertically
            anchors {
                left: parent.right
                top: parent.top
                bottom: parent.bottom
                leftMargin: -1
            }
        }
        PlasmaCore.FrameSvgItem {
            id: handleGraphics
            imagePath: "dialogs/background"
            enabledBorders: "LeftBorder|TopBorder|BottomBorder"
            width: handleIcon.width + margins.left + margins.right + 4
            height: handleIcon.width * 1.6 + margins.top + margins.bottom + 4
            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
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
                target: browserFrame
                axis: Drag.XAxis
                //-50, an overshoot to make it look smooter
                minimumX: -sidebar.width - 50
                maximumX: 0
            }
            property int startX
            property bool toggle: true
            onPressed: {
                startX = browserFrame.x
                toggle = true
            }
            onPositionChanged: {
                if (Math.abs(browserFrame.x - startX) > 20) {
                    toggle = false
                }
            }
            onReleased: {
                if (toggle) {
                    sidebar.open = !sidebar.open
                } else {
                    sidebar.open = (browserFrame.x < -sidebar.width/2)
                }
                sidebarSlideAnimation.to = sidebar.open ? -sidebar.width : 0
                sidebarSlideAnimation.running = true
            }
        }
        //FIXME: use a state machine
        SequentialAnimation {
            id: sidebarSlideAnimation
            property alias to: actualSlideAnimation.to
            NumberAnimation {
                id: actualSlideAnimation
                target: browserFrame
                properties: "x"
                duration: 250
                easing.type: Easing.InOutQuad
            }
            ScriptAction {
                script: mainPage.anchors.leftMargin = -browserFrame.x
            }
        }
    }

    Item {
        id: sidebar

        property bool open: false

        width: parent.width/4
        x: parent.width - width
        Behavior on width {
            NumberAnimation {
                duration: 250
                easing.type: Easing.InOutQuad
            }
        }
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

    ParallelAnimation {
        id: positionAnim
        property Item target
        property int x
        property int y
        NumberAnimation {
            target: positionAnim.target
            to: positionAnim.y
            properties: "y"

            duration: 250
            easing.type: Easing.InOutQuad
        }
        NumberAnimation {
            target: positionAnim.target
            to: positionAnim.x
            properties: "x"

            duration: 250
            easing.type: Easing.InOutQuad
        }
    }
}

