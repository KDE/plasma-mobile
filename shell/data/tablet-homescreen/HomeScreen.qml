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

    Item {
        id: mainSlot;
        objectName: "mainSlot";
        x: 0;
        y: 0;
        width: homescreen.width;
        height: homescreen.height;
        transformOrigin : Item.Center;
    }

    Dragger {
        id: prevDrag

        location: "LeftEdge"
        targetItem: spareSlot

        onTransitionFinished : {
            homescreen.transitionFinished();
            state = "hidden"
        }
        onActivated: homescreen.previousActivityRequested();
        onDeactivated: {
            if (state == "hidden") {
                homescreen.nextActivityRequested();
                homescreen.transitionFinished();
            }
        }
    }

    Dragger {
        id: nextDrag
        objectName: "nextDrag"

        location: "RightEdge"
        targetItem: spareSlot

        onTransitionFinished : {
            homescreen.transitionFinished()
            state = "hidden"
        }
        onActivated: homescreen.nextActivityRequested();
        onDeactivated: {
            if (state == "hidden") {
                homescreen.previousActivityRequested();
                homescreen.transitionFinished();
            }
        }
    }

    Item {
        id : spareSlot;
        objectName: "spareSlot";
        x: -homescreen.width;
        y: 0;
        width: homescreen.width;
        height: homescreen.height;
    }

    Image {
        source: "images/shadow-right.png"
        anchors.left: spareSlot.right
        width: 12
        height: spareSlot.height
    }
    Image {
        source: "images/shadow-left.png"
        anchors.right: spareSlot.left
        width: 12
        height: spareSlot.height
    }

    Item {
        id: alternateSlot;
        objectName: "alternateSlot";
        x: 0;
        y: alternateDrag.y + alternateDrag.height;
        width: homescreen.width;
        height: homescreen.height;
    }
    Image {
        source: "images/shadow-top.png"
        anchors.bottom: alternateSlot.top
        width: alternateSlot.width
        height: 12
    }
    Image {
        source: "images/shadow-bottom.png"
        anchors.top: alternateSlot.bottom
        width: alternateSlot.width
        height: 12
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
    }


}
