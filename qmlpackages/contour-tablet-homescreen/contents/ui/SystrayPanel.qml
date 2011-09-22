/***************************************************************************
 *   Copyright 2010 Lim Yuen Hoe <yuenhoe@hotmail.com>                     *
 *   Copyright 2011 Davide Bettio <bettio@kde.org>                         *
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

import Qt 4.7
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents

Item {
    id: systrayPanel
    state: "Hidden"
    width: Math.max(800, homeScreen.width)
    height: Math.max(480, homeScreen.height - 50 + background.margins.bottom + 200)
    onStateChanged: {
        if (menuContainer.plasmoid && (state == "Hidden" || state == "Tasks")) {
            menuContainer.plasmoid.resetStatus()
        }
    }

    PlasmaCore.FrameSvgItem {
        id: background
        anchors.fill:parent
        imagePath: "widgets/panel-background"
        enabledBorders: "BottomBorder"
    }

    MobileComponents.Package {
        id: launcherPackage
        name: "org.kde.active.launcher"
        Component.onCompleted: {
            var component = Qt.createComponent(launcherPackage.filePath("mainscript"));
            menuContainer.plasmoid = component.createObject(menuContainer);
            //assume menuContainer provides a itemLaunched signal
            if (menuContainer.plasmoid) {
                menuContainer.plasmoid.itemLaunched.connect(systrayPanel.itemLaunched)
            }
        }
    }

    function itemLaunched()
    {
        systrayPanel.state = "Hidden"
    }

    function addContainment(cont)
    {
        if (cont.pluginName == "org.kde.windowstrip") {
            windowListContainer.plasmoid = cont
        } else if (cont.pluginName == "org.kde.active.systemtray") {
            systrayContainer.plasmoid = cont
        }
    }

    SlidingDragButton {
        id: slidingDragButton
        panelHeight: 32
        tasksHeight: 150

        anchors {
            fill: parent
            bottomMargin: background.margins.bottom
        }

        Image {
            source: homeScreenPackage.filePath("images", "fabrictexture.png")
            fillMode: Image.Tile
            height: menuContainer.height-8
            anchors {
                left: parent.left
                right: parent.right
            }
        }

        Column {
            id: itemColumn
            anchors.fill: parent
            spacing: 4

            PlasmoidContainer {
                id: menuContainer
                anchors {
                    left: parent.left
                    right: parent.right
                }
                height: parent.height - (itemColumn.spacing * 3) - systrayContainer.height - windowListContainer.height - 2
                Image {
                    source: homeScreenPackage.filePath("images", "shadow-top.png")
                    fillMode: Image.TileHorizontally
                    height: sourceSize.height
                    anchors {
                        left: parent.left
                        right: parent.right
                        bottom: parent.bottom
                        bottomMargin: 8
                    }
                }
            }
            PlasmoidContainer {
                id: windowListContainer
                anchors {
                    left: parent.left
                    right: parent.right
                }
                height: slidingDragButton.tasksHeight
            }
            Item {
                width: 2
                height: 2
            }
            PlasmoidContainer {
                id: systrayContainer
                anchors {
                    left: parent.left
                    right: parent.right
                    rightMargin: 32
                }
                height: slidingDragButton.panelHeight
            }
        }
    }

    states:  [
        State {
            name: "Full"
            PropertyChanges {
                target: slidingPanel
                y: -200
            }
            PropertyChanges {
                target: slidingPanel
                acceptsFocus: true
            }
        },
        State {
            name: "Launcher"
            PropertyChanges {
                target: slidingPanel
                y: 0
            }
            PropertyChanges {
                target: slidingPanel
                acceptsFocus: true
            }
        },
        State {
            name: "Hidden"
            PropertyChanges {
                target: slidingPanel
                y: -topEdgePanel.height + systrayContainer.height+ background.margins.bottom + 2
            }
            PropertyChanges {
                target: slidingPanel
                acceptsFocus: false
            }
        },
        State {
            name: "Tasks"
            PropertyChanges {
                target: slidingPanel
                y: -topEdgePanel.height + systrayContainer.height + windowListContainer.height + background.margins.bottom

                acceptsFocus: true
            }
        }
    ]
    transitions: [
        Transition {
            SequentialAnimation {
                PropertyAction { 
                    target: slidingPanel
                    property: "acceptsFocus"
                }
                PropertyAnimation {
                    properties: "y"
                    duration: 250
                    easing.type: Easing.OutQuad
                }
            }
        }
    ]
}
