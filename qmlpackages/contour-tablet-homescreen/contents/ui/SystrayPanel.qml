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
import org.kde.plasma.extras 0.1 as PlasmaExtras
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents

Image {
    source: "image://appbackgrounds/standard"
    fillMode: Image.Tile
    id: systrayPanel
    state: "Hidden"
    width: Math.max(800, homeScreen.width)
    height: Math.max(480+systrayContainer.height+8, homeScreen.height - 50 + background.margins.bottom)
    property bool windowStripVisible: false
    property alias containment: systrayContainer.plasmoid
    property int panelHeight: systrayContainer.height + background.margins.bottom*2

    onStateChanged: {
        if (menuContainer.plasmoid && (state == "Hidden" || state == "Tasks")) {
            menuContainer.plasmoid.resetStatus()
        }
    }

    PlasmaCore.FrameSvgItem {
        id: background
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        height: systrayContainer.height + margins.bottom*2
        imagePath: "widgets/panel-background"
        enabledBorders: "BottomBorder"
    }

    MobileComponents.Package {
        id: launcherPackage
        name: "org.kde.active.launcher"
    }

    function itemLaunched()
    {
        systrayPanel.state = "Hidden"
    }

    function setWindowListArea()
    {
        topSlidingPanel.windowListArea = Qt.rect(windowListContainer.x, windowListContainer.y, windowListContainer.width, windowListContainer.height)
    }

    //The launcher package is created after some time to not slow boot time
    Timer {
        running: true
        interval: 3000
        onTriggered: {
            if (!menuContainer.plasmoid) {
                var component = Qt.createComponent(launcherPackage.filePath("mainscript"));
                menuContainer.plasmoid = component.createObject(menuContainer);
                //assume menuContainer provides a itemLaunched signal
                if (menuContainer.plasmoid) {
                    menuContainer.plasmoid.itemLaunched.connect(systrayPanel.itemLaunched)
                }
            }
        }
    }
    SlidingDragButton {
        id: slidingDragButton
        panelHeight: theme.defaultFont.mSize.height * 2
        tasksHeight: homeScreen.height/4.5
        onDraggingChanged: {
            if (dragging) {
                systrayPanel.windowStripVisible = true;
            }
        }

        anchors.fill: parent

        Column {
            id: itemColumn
            anchors {
                fill: parent
                bottomMargin: background.margins.bottom
            }
            spacing: 4

            PlasmoidContainer {
                id: menuContainer
                anchors {
                    left: parent.left
                    right: parent.right
                }
                height: parent.height - (itemColumn.spacing * 3) - systrayContainer.height - windowListContainer.height - 2
                Image {
                    source: "image://appbackgrounds/shadow-top"
                    fillMode: Image.StretchHorizontally
                    height: sourceSize.height
                    z: 800
                    anchors {
                        left: parent.left
                        right: parent.right
                        bottom: parent.bottom
                        bottomMargin: -1
                    }
                }
            }
            Item {
                id: windowListContainer
                anchors {
                    left: parent.left
                    right: parent.right
                }
                height: slidingDragButton.tasksHeight

                onXChanged: {
                    setWindowListArea();
                }

                onYChanged: {
                    setWindowListArea();
                }

                onHeightChanged: {
                    setWindowListArea();
                }

                onWidthChanged: {
                    setWindowListArea();
                }
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
                    rightMargin: slidingDragButton.homeButtonShown ? 32 : 0
                }
                height: slidingDragButton.panelHeight
            }
        }
    }

    states:  [
        State {
            name: "Launcher"
            PropertyChanges {
                target: topSlidingPanel
                y: 0
                acceptsFocus: true
            }
        },
        State {
            name: "Hidden"
            PropertyChanges {
                target: topSlidingPanel
                y: -topEdgePanel.height + systrayContainer.height + background.margins.bottom*2
                acceptsFocus: false
            }
        },
        State {
            name: "Tasks"
            PropertyChanges {
                target: topSlidingPanel
                y: -topEdgePanel.height + systrayContainer.height + windowListContainer.height + background.margins.bottom*2

                acceptsFocus: true
            }
        }
    ]
    transitions: [
        Transition {
            SequentialAnimation {
                PropertyAnimation {
                    properties: "y"
                    duration: 250
                    easing.type: Easing.OutQuad
                }
                ScriptAction {
                    script: {
                        if (state == "Hidden") {
                            systrayPanel.windowStripVisible = false
                        } else {
                            systrayPanel.windowStripVisible = true
                        }
                    }
                }
            }
        }
    ]
}
