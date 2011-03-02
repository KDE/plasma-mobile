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

Item {
    id: homescreen;
    objectName: "homeScreen";
    x: 0;
    y: 0;
    width: 800;
    height: 480;
    signal transitionFinished();
    signal nextActivityRequested();
    signal previousActivityRequested();
    state : "Normal";

    //this item will define Corona::screenGeometry() and Corona::availableScreenRegion()
    Item {
        id: screenGeometry
        objectName: "screenGeometry"
        anchors.fill: parent
        anchors.topMargin: 24
        anchors.bottomMargin: 24

        //this properties will define "structs" for reserved screen of the panels
        property int leftReserved: 0
        property int topReserved: anchors.topMargin
        property int rightReserved: 0
        property int bottomReserved: 0
    }

    Item {
        id: mainSlot;
        objectName: "mainSlot";
        x: 0;
        y: 0;
        width: homescreen.width;
        height: homescreen.height;
        transformOrigin : Item.Center;
    }

    Item {
        id : spareSlot;
        objectName: "spareSlot";
        x: -homescreen.width;
        y: 0;
        width: homescreen.width;
        height: homescreen.height;
    }

    Shadow {
        id: spareSlotShadowRight
        source: "images/shadow-right.png"
        anchors.left: spareSlot.right
        anchors.leftMargin: -1
        width: 11
        height: spareSlot.height
        
    }
    Shadow {
        id: spareSlotShadowLeft
        source: "images/shadow-left.png"
        anchors.right: spareSlot.left
        anchors.rightMargin: -1
        width: 11
        height: spareSlot.height
    }

    Dragger {
        id: prevDrag

        location: "LeftEdge"
        targetItem: spareSlot

        onTransitionFinished : {
            if (state == "show") {
                homescreen.transitionFinished()
                state = "hidden"
            }
            spareSlotShadowRight.state = "invisible"
        }
        onActivated: {
            homescreen.previousActivityRequested();
            spareSlotShadowRight.state = "visible"
        }
    }

    Dragger {
        id: nextDrag
        objectName: "nextDrag"

        location: "RightEdge"
        targetItem: spareSlot

        onTransitionFinished : {
            if (state == "show") {
                homescreen.transitionFinished()
                state = "hidden"
            }
            spareSlotShadowLeft.state = "invisible"
        }
        onActivated: {
            homescreen.nextActivityRequested();
            spareSlotShadowLeft.state = "visible"
        }
    }

    Item {
        id: alternateSlot;
        objectName: "alternateSlot";
        x: 0;
        y: alternateDrag.y + alternateDrag.height;
        width: homescreen.width;
        height: homescreen.height;
    }
    Shadow {
        id: alternateSlotShadowTop
        source: "images/shadow-top.png"
        anchors.bottom: alternateSlot.top
        anchors.topMargin: -1
        width: alternateSlot.width
        height: 11
    }
    Shadow {
        id: alternateSlotShadowBottom
        source: "images/shadow-bottom.png"
        anchors.top: alternateSlot.bottom
        anchors.topMargin: -1
        width: alternateSlot.width
        height: 11
    }

    SystrayPanel {
        id: systraypanel;
        objectName: "systraypanel";

        anchors.horizontalCenter: homescreen.horizontalCenter;
        y: 0;
    }

    Dragger {
        id: alternateDrag

        location: "BottomEdge"
        targetItem: alternateSlot
        onTransitionFinished : {
            alternateSlotShadowBottom.state = "invisible"
            alternateSlotShadowTop.state = "invisible"
        }

        onActivated: {
            alternateSlotShadowBottom.state = "visible"
            alternateSlotShadowTop.state = "visible"        
        }
    }

    //FIXME: this should be automatic
    onWidthChanged: {
        prevDrag.updateDrag();
        nextDrag.updateDrag();
        alternateDrag.updateDrag();
    }
    onHeightChanged: {
        prevDrag.updateDrag();
        nextDrag.updateDrag();
        alternateDrag.updateDrag();
    }

}
