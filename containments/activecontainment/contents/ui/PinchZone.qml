/*
 *   Copyright 2011 Marco Martin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2 or
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

import QtQuick 1.0
import Qt.labs.gestures 2.0

GestureArea {
    id: pinchZone
    anchors.fill: parent
    property int startX
    property int startY

    Pinch {
        onStarted: {
            itemGroup.z = 999
            mouse.accepted = true
            //FIXME: this shouldn't be necessary
            mainFlickable.interactive = false
            animationsEnabled = false
            /*startX = mouse.x
            startY = mouse.y*/
            LayoutManager.setSpaceAvailable(itemGroup.x, itemGroup.y, itemGroup.width, itemGroup.height, true)
            //debugFlow.refresh();
        }

        onUpdated: {
            var xScale = gesture.scaleFactor*Math.cos(Math.PI/180*gesture.rotationAngle)
            var yScale = gesture.scaleFactor*Math.sin(Math.PI/180*gesture.rotationAngle)

            var ratio = itemGroup.width/itemGroup.height
            var area = itemGroup.width*itemGroup.height*gesture.scaleFactor
            //TODO: height as well if it's going to become a grid view
            itemGroup.width = Math.max(itemGroup.minimumWidth, Math.sqrt(area*ratio))
            if (itemGroup.canResizeHeight) {
                itemGroup.height = Math.max(itemGroup.minimumHeight, area/itemGroup.width)
            }
        }

        onFinished: {
            animationsEnabled = true

            LayoutManager.positionItem(itemGroup)
            LayoutManager.save()
            LayoutManager.setSpaceAvailable(itemGroup.x, itemGroup.y, widthAnimation.to, heightAnimation.to, false)
            //debugFlow.refresh();
        }
    }
}

