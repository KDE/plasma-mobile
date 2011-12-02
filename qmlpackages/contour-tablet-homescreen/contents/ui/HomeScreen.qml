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

import QtQuick 1.0
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.deviceshell 0.1 as DeviceShell
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents

Item {
    id: homeScreen;
    objectName: "homeScreen";
    x: 0;
    y: 0;
    width: 800;
    height: 480;
    state : "Normal"
    signal nextActivityRequested
    signal previousActivityRequested
    signal newActivityRequested
    signal transformingChanged(bool transforming)
    signal focusActivityView

    property QtObject activeWallpaper
    onActiveWallpaperChanged: {
        print("Current wallpaper path"+activeWallpaper.wallpaperPath);
    }

    MobileComponents.Package {
        id: homeScreenPackage
        name: "org.kde.active.contour-tablet-homescreen"
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
        finishTransition()
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

        //hide the activity switcher
        if (activityPanel) {
            activityPanel.x = homeScreen.width
            activityPanel.state = "hidden"
        }

        state = "Normal"
    }

    PlasmaCore.Theme {
        id: theme
    }

    //this item will define Corona::availableScreenRegion() for simplicity made by a single rectangle
    Item {
        id: availableScreenRect
        objectName: "availableScreenRect"
        anchors.fill: parent
        anchors.topMargin: 38
        anchors.bottomMargin: 12

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

    MobileComponents.MouseEventListener {
        id: mainSlot;
        objectName: "mainSlot"
        x: 0;
        y: 0;
        width: homeScreen.width
        height: homeScreen.height
        property QGraphicsWidget containment
        onPressed: {
            if (activityPanel && mouse.x < activityPanel.x) {
                activityPanel.state = "hidden"
            }
            if (mouse.x > recommendationsPanel.x+recommendationsPanel.width) {
                recommendationsPanel.state = "hidden"
            }
        }
    }


    states: [
            State {
                name: "Normal"
                PropertyChanges {
                    target: spareSlot;
                    x: homeScreen.width
                }

            },
            State {
                name: "Slide"
                PropertyChanges {
                    target: spareSlot;
                    x: 0
                }
            }
    ]


    //acceptsFocus property is costly, delay it after the animation
    Timer {
        id: topEdgePanelStateTimer
        interval: 500
        repeat: false
        running: false
        onTriggered: {
            topEdgePanel.state = "Hidden"
        }
    }

    DeviceShell.DevicePanel {
        id: topSlidingPanel
        visible: true
        mainItem: SystrayPanel {
            id: topEdgePanel
            objectName: "topEdgePanel"
        }
        onActiveWindowChanged: {
            if (acceptsFocus && !activeWindow) {
                topEdgePanelStateTimer.restart()
            }
        }
    }

    property Item recommendationsPanel
    property Item activityPanel
    Timer {
        id: panelsCreationTimer
        interval: 2000
        repeat: false
        running: true
        onTriggered: {
            homeScreen.recommendationsPanel = recommendationsPanelComponent.createObject(homeScreen)
            homeScreen.activityPanel = activityPanelComponent.createObject(homeScreen)
        }
    }
    Component {
        id: recommendationsPanelComponent
        RecommendationsPanel {
            id: recommendationsPanel

            anchors {
                top: parent.top
                bottom: parent.bottom
            }
            x: - width
        }
    }


    Component {
        id: activityPanelComponent
        ActivityPanel {
            id: activityPanel
            x: parent.width - width
        }
    }

    Item {
        id : spareSlot
        objectName: "spareSlot"
        x: 0
        y: 0
        width: homeScreen.width
        height: homeScreen.height
        property QGraphicsWidget containment
    }
}
