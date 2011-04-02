/***************************************************************************
 *   Copyright 2010 Alexis Menard <menard@kde.org>                         *
 *   Copyright 2010 Artur Duque de Souza <asouza@kde.org>                  *
 *   Copyright 2010 Marco Martin <mart@kde.org>                            *
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
import org.kde.plasma.graphicswidgets 0.1 as PlasmaWidgets
import org.kde.plasma.core 0.1 as PlasmaCore

Item {
    id: homeScreen;
    objectName: "homeScreen";
    x: 0;
    y: 0;
    width: 800;
    height: 480;
    signal nextActivityRequested();
    signal previousActivityRequested();
    state : "Normal"
    signal transformingChanged(bool transforming)
    property bool locked: true

    property QtObject activeWallpaper
    onActiveWallpaperChanged: {
        print("Current wallpaper path"+activeWallpaper.wallpaperPath);
    }

    property QGraphicsWidget activeContainment
    onActiveContainmentChanged: {
        activeContainment.visible=true
        spareSlot.containment = activeContainment
        activeContainment.parent = spareSlot
        activeContainment.visible = true
        activeContainment.x = 0
        activeContainment.y = 0
        activeContainment.size = width + "x" + height
        //view the main containment
        state = "Slide"
        transformingChanged(true);
    }

    function finishTransition()
    {
        //spareSlot.containment = undefined
        if (mainSlot.containment) {
            mainSlot.containment.visible = false
        }
        mainSlot.containment = activeContainment
        activeContainment.parent = mainSlot
        activeContainment.x = 0
        activeContainment.y = 0
        state = "Normal"
        transformingChanged(false);
        switcher.current=0
    }

    onLockedChanged: {
        if (locked) {
            lockScreenItem.x = 0
            lockScreenItem.y = 0
            unlockTextAnimation.running = true
        } else if (lockScreenItem.x == 0 && lockScreenItem.y == 0) {
            lockScreenItem.x = 0
            lockScreenItem.y = homeScreen.height
        }
    }

    PlasmaCore.Theme {
        id: theme
    }

    Image {
        //TODO: take scale mode from Wallpaper config
        asynchronous: true
        source: activeWallpaper.wallpaperPath
        width: Math.max(homeScreen.width, sourceSize.width)
        height: Math.max(homeScreen.height, sourceSize.height)
        //Parallax: the background moves for is width
        x: (mainContainments.width-width)*(1-((mainContainments.x+mainContainments.width)/(mainContainments.width*3)))
    }

    //this item will define Corona::availableScreenRegion() for simplicity made by a single rectangle
    Item {
        id: availableScreenRect
        objectName: "availableScreenRect"
        anchors.fill: parent
        anchors.topMargin: 32
        anchors.bottomMargin: 28

        //this properties will define "structs" for reserved screen of the panels
        property int leftReserved: 0
        property int topReserved: anchors.topMargin
        property int rightReserved: 0
        property int bottomReserved: 0
    }

    Item {
        id: alternateSlot;
        objectName: "alternateSlot";
        x: -width
        y: 0
        width: homeScreen.width;
        height: homeScreen.height;
    }

    Item {
        id: mainContainments
        width: homeScreen.width
        height: homeScreen.height
        x: 0
        y: 0

        Item {
            id: mainSlot;
            objectName: "mainSlot"
            x: 0;
            y: 0;
            width: homeScreen.width
            height: homeScreen.height
            property QGraphicsWidget containment
        }

        Item {
            id : spareSlot
            objectName: "spareSlot"
            x: homeScreen.width
            y: 0
            z: 9999
            width: homeScreen.width
            height: homeScreen.height
            property QGraphicsWidget containment
        }

        
        Item {
            //FIXME: shouldn't be a panel with that design, excludefromactivities containment assignments should be refactored
            id: activitySlot
            objectName: "activitySlot"

            x: homeScreen.width
            y: 0
            width: homeScreen.width;
            height: homeScreen.height
        }
    }

    Switcher {
        id: switcher
    }

    states: [
            State {
                name: "Normal"
                /*PropertyChanges {
                    target: mainSlot;
                    y: 0;
                }
                PropertyChanges {
                    target: spareSlot;
                    y: -homeScreen.height;
                }*/
                PropertyChanges {
                    target: spareSlot;
                    scale: 0.3;
                }
                PropertyChanges {
                    target: spareSlot;
                    opacity: 0;
                }

            },
            State {
                name: "Slide"
                PropertyChanges {
                    target: spareSlot;
                    y: 0;
                }
                PropertyChanges {
                    target: spareSlot;
                    scale: 1;
                }
                PropertyChanges {
                    target: spareSlot;
                    opacity: 1;
                }
                /*PropertyChanges {
                    target: mainSlot;
                    y: homeScreen.height;
                }*/
            }
    ]

    transitions: Transition {
            from: "Normal"
            to: "Slide"
            SequentialAnimation {

                ParallelAnimation {
                    NumberAnimation {
                        target: spareSlot;
                        property: "opacity";
                        easing.type: "OutQuad";
                        duration: 300;
                    }
                    NumberAnimation {
                        target: spareSlot;
                        property: "scale";
                        easing.type: "OutQuad";
                        duration: 300;
                    }
                }
                ScriptAction {
                    script: finishTransition();
                }
            }
        }


    SystrayPanel {
        id: topEdgePanel;
        objectName: "topEdgePanel";

        anchors.horizontalCenter: homeScreen.horizontalCenter;
        y: 0;
    }



    Rectangle {
        id: lockScreenItem
        width: parent.width
        height: parent.height
        color: Qt.rgba(0, 0, 0, 0.8)

        Text {
            id: unlockText
            text: "Drag away to unlock"
            color: "white"
            anchors.centerIn: parent
            font.pixelSize: 30
            opacity: 0
            Component.onCompleted: {
                unlockTextAnimation.running = true
            }
        }
        SequentialAnimation {
            id: unlockTextAnimation
            running: false
            NumberAnimation {
                target: unlockText
                property: "opacity"
                to: 1
                duration: 1000
            }
            PauseAnimation { duration: 5000 }
            NumberAnimation {
                target: unlockText
                property: "opacity"
                to: 0
                duration: 1000
            }
        }

        MouseArea {
            anchors.fill: parent
            drag.target: lockScreenItem
            onReleased: {
                var lockedX = false
                var lockedY = false
                if (lockScreenItem.x > homeScreen.width/3) {
                    lockScreenItem.x = homeScreen.width
                } else if (lockScreenItem.x < -homeScreen.width/3) {
                    lockScreenItem.x = -homeScreen.width
                } else {
                    lockScreenItem.x = 0
                    lockedX = true
                }

                if (lockScreenItem.y > homeScreen.height/3) {
                    lockScreenItem.y = homeScreen.height
                } else if (lockScreenItem.y < -homeScreen.height/3) {
                    lockScreenItem.y = -homeScreen.height
                } else {
                    lockScreenItem.y = 0
                    lockedY = true
                }
                if (lockedX && lockedY) {
                    homeScreen.locked = true
                } else {
                    homeScreen.locked = false
                }
            }
        }
        Behavior on x {
            NumberAnimation { duration: 250 }
        }
        Behavior on y {
            NumberAnimation { duration: 250 }
        }
    }
}
