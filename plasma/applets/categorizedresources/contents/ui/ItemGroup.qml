/*
 *   Copyright 2011 Sebastian Kügler <sebas@kde.org>
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
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 1.0
import org.kde.plasma.graphicswidgets 0.1 as PlasmaWidgets
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents
import "plasmapackage:/code/LayoutManager.js" as LayoutManager

PlasmaCore.FrameSvgItem {
    id: itemGroup
    property string category
    property alias categoryCount: itemsList.count
    imagePath: "widgets/background"
    width: LayoutManager.cellSize.width*2
    height: LayoutManager.cellSize.height
    z: 0
    property bool animationsEnabled: false
    scale: itemsList.count>0?1:0

    MouseArea {
        anchors.fill: parent
        drag.target: parent
        onPressed: {
            itemGroup.z = 999
            animationsEnabled = false
            mouse.accepted = true
            var x = Math.round(parent.x/LayoutManager.cellSize.width)*LayoutManager.cellSize.width
            var y = Math.round(parent.y/LayoutManager.cellSize.height)*LayoutManager.cellSize.height
            LayoutManager.setSpaceAvailable(x, y, parent.width, parent.height, true)

            debugFlow.refresh();


            placeHolder.syncWithItem(parent)
            placeHolderPaint.opacity = 1
        }
        onPositionChanged: {
            placeHolder.syncWithItem(parent)

            var globalPos = mapToItem(main, x, y)
            if (!scrollTimer.running && globalPos.y < 100) {
                scrollTimer.backwards = true
                scrollTimer.running = true
                scrollTimer.draggingItem = itemGroup
            } else if (!scrollTimer.running && globalPos.y > main.height-100) {
                scrollTimer.backwards = false
                scrollTimer.running = true
                scrollTimer.draggingItem = itemGroup
            } else if (scrollTimer.running) {
                scrollTimer.running = false
            }
        }
        onReleased: {
            scrollTimer.running = false
            placeHolderPaint.opacity = 0
            itemGroup.z = 0
            animationsEnabled = true
            LayoutManager.positionItem(parent)
            debugFlow.refresh()
        }
    }
    Behavior on scale {
        NumberAnimation {
            duration: 250
            easing.type: Easing.InOutQuad
        }
    }
    Behavior on x {
        enabled: animationsEnabled
        NumberAnimation {
            duration: 250
            easing.type: Easing.InOutQuad
        }
    }
    Behavior on y {
        enabled: animationsEnabled
        NumberAnimation {
            duration: 250
            easing.type: Easing.InOutQuad
        }
    }
    Behavior on width {
        enabled: animationsEnabled
        NumberAnimation {
            id: widthAnimation
            duration: 250
            easing.type: Easing.InOutQuad
        }
    }
    Behavior on height {
        enabled: animationsEnabled
        NumberAnimation {
            duration: 250
            easing.type: Easing.InOutQuad
        }
    }
    MouseArea {
        id: resizeHandle
        width: 48
        height: 48
        anchors {
            right: parent.right
            bottom: parent.bottom
            rightMargin: -16
        }

        property int startX
        property int startY

        onPressed: {
            mouse.accepted = true
            //FIXME: this shouldn't be necessary
            mainFlickable.interactive = false
            animationsEnabled = false
            startX = mouse.x
            startY = mouse.y
            LayoutManager.setSpaceAvailable(itemGroup.x, itemGroup.y, itemGroup.width, itemGroup.height, true)
            debugFlow.refresh();
        }
        onPositionChanged: {
            //TODO: height as well if it's going to become a grid view
            itemGroup.width = Math.max(LayoutManager.cellSize.width, itemGroup.width + mouse.x-startX)
        }
        onReleased: {
            animationsEnabled = true

            mainFlickable.interactive = true
            LayoutManager.positionItem(parent)
            LayoutManager.setSpaceAvailable(itemGroup.x, itemGroup.y, widthAnimation.to, itemGroup.height, false)
            debugFlow.refresh();
        }
    }
    Component.onCompleted: {
        //width = Math.min(470, 32+itemsList.count*140)
        layoutTimer.running = true
        layoutTimer.restart()
        enabled = false
        visible = false
    }

    PlasmaCore.FrameSvgItem {
        id: categoryTitle
        imagePath: "widgets/extender-dragger"
        prefix: "root"
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            leftMargin: parent.margins.left
            rightMargin: parent.margins.right
            topMargin: parent.margins.top
        }
        height: categoryText.height + margins.top + margins.bottom
        Text {
            id: categoryText
            text: i18n("%1 (%2)", itemGroup.category, itemsList.count)
            anchors {
                top: parent.top
                horizontalCenter: parent.horizontalCenter
                topMargin: parent.margins.top
            }
        }
    }

    ItemsList {
        id: itemsList
    }
}
