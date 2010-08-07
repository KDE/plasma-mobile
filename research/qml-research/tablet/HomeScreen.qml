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
    state : "Normal";

    Image {
        id: mainSlot;
        objectName: "mainSlot";
        source: "images/activity1.png"
        x: 0;
        y: 0;
        width: homescreen.width;
        height: homescreen.height;
        transformOrigin : Item.Center;
    }

    Rectangle {
        id : spareSlotPrev;
        objectName: "spareSlotPrev";
        color: "green"
        x: -homescreen.width;
        y: 0;
        width: homescreen.width;
        height: homescreen.height;
    }

    Rectangle {
        id : spareSlotNext;
        objectName: "spareSlotNext";
        color: "blue"
        x: homescreen.width;
        y: 0;
        width: homescreen.width;
        height: homescreen.height;
    }

    Image {
        id: alternateSlot;
        source: "images/activity0.png"
        objectName: "alternateSlot";
        x: 0;
        y: alternateDrag.y + alternateDrag.height;
        width: homescreen.width;
        height: homescreen.height;
    }


    Rectangle {
        id: systraypanel;
        objectName: "systraypanel";
        color: "black"
        anchors.horizontalCenter: homescreen.horizontalCenter;
        width: 200
        height: 24
        y: 0;
    }

    Dragger {
        id: alternateDrag

        location: "BottomEdge"
        targetItem: alternateSlot
    }

    Dragger {
        id: prevDrag

        location: "LeftEdge"
        targetItem: spareSlotPrev
    }

    Dragger {
        id: nextDrag

        location: "RightEdge"
        targetItem: spareSlotNext
    }


}
