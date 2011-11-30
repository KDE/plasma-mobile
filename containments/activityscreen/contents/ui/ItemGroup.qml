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
 *   GNU Library General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 1.0
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents
import "plasmapackage:/code/LayoutManager.js" as LayoutManager

PlasmaCore.FrameSvgItem {
    id: itemGroup
    property string category
    property string title
    property bool canResizeHeight: false
    imagePath: "widgets/background"
    width: LayoutManager.cellSize.width*2
    height: LayoutManager.cellSize.height
    z: 0
    property bool animationsEnabled: false
    property int minimumWidth: LayoutManager.cellSize.width
    property int minimumHeight: LayoutManager.cellSize.height
    property int titleHeight: categoryTitle.height

    property Item contents: contentsItem
    Item {
        id: contentsItem
        anchors {
            left: parent.left
            top: parent.top
            right: parent.right
            bottom: parent.bottom
            topMargin: parent.margins.top+itemGroup.titleHeight
            leftMargin: parent.margins.left
            rightMargin: parent.margins.right
            bottomMargin: parent.margins.bottom
        }
    }

    MouseArea {
        anchors.fill: parent
        property int lastX
        property int lastY

        onPressed: {
            //FIXME: this shouldn't be necessary
            mainFlickable.interactive = false
            itemGroup.z = 999
            animationsEnabled = false
            mouse.accepted = true
            var x = Math.round(parent.x/LayoutManager.cellSize.width)*LayoutManager.cellSize.width
            var y = Math.round(parent.y/LayoutManager.cellSize.height)*LayoutManager.cellSize.height
            LayoutManager.setSpaceAvailable(x, y, parent.width, parent.height, true)

            var globalMousePos = mapToItem(main, mouse.x, mouse.y)
            lastX = globalMousePos.x
            lastY = globalMousePos.y

            //debugFlow.refresh();


            placeHolder.syncWithItem(parent)
            placeHolderPaint.opacity = 1
        }
        onPositionChanged: {
            placeHolder.syncWithItem(parent)

            var globalPos = mapToItem(main, x, y)

            var globalMousePos = mapToItem(main, mouse.x, mouse.y)
            itemGroup.x += (globalMousePos.x - lastX)
            itemGroup.y += (globalMousePos.y - lastY)

            lastX = globalMousePos.x
            lastY = globalMousePos.y

            if (globalPos.y < 100) {
                scrollTimer.backwards = true
                scrollTimer.running = true
                scrollTimer.draggingItem = itemGroup
            } else if (globalPos.y > main.height-100) {
                scrollTimer.backwards = false
                scrollTimer.running = true
                scrollTimer.draggingItem = itemGroup
            } else if (scrollTimer.running) {
                scrollTimer.running = false
            }
        }
        onReleased: {
            scrollTimer.running = false
            repositionTimer.running = false
            placeHolderPaint.opacity = 0
            animationsEnabled = true
            LayoutManager.positionItem(itemGroup)
            LayoutManager.save()
            //debugFlow.refresh()
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
            onRunningChanged: {
                if (!running) {
                    itemGroup.z = 0
                }
            }
        }
    }
    Behavior on y {
        enabled: animationsEnabled
        NumberAnimation {
            duration: 250
            easing.type: Easing.InOutQuad
            onRunningChanged: {
                if (!running) {
                    mainFlickable.interactive = contentItem.height>mainFlickable.height
                    if (!mainFlickable.interactive) {
                        contentScrollTo0Animation.running = true
                    }
                }
            }
        }
    }
    Behavior on width {
        enabled: animationsEnabled
        NumberAnimation {
            id: widthAnimation
            duration: 250
            easing.type: Easing.InOutQuad
            onRunningChanged: {
                if (!running) {
                    itemGroup.z = 0
                }
            }
        }
    }
    Behavior on height {
        enabled: animationsEnabled
        NumberAnimation {
            id: heightAnimation
            duration: 250
            easing.type: Easing.InOutQuad
            onRunningChanged: {
                if (!running) {
                    mainFlickable.interactive = contentItem.height>mainFlickable.height
                    if (!mainFlickable.interactive) {
                        contentScrollTo0Animation.running = true
                    }
                }
            }
        }
    }

    PlasmaCore.SvgItem {
        svg: PlasmaCore.Svg {
            imagePath: plasmoid.file("images", "resize-handle.svgz")
        }
        width: 24
        height: 24
        anchors {
            right: parent.right
            bottom: parent.bottom
            rightMargin: itemGroup.margins.right
            bottomMargin: itemGroup.margins.bottom
        }
    }
    MouseArea {
        id: resizeHandle
        width: 48
        height: 48
        z: 9999
        anchors {
            right: parent.right
            bottom: parent.bottom
            rightMargin: -16
        }

        property int startX
        property int startY

        onPressed: {
            itemGroup.z = 999
            mouse.accepted = true
            //FIXME: this shouldn't be necessary
            mainFlickable.interactive = false
            animationsEnabled = false
            startX = mouse.x
            startY = mouse.y
            LayoutManager.setSpaceAvailable(itemGroup.x, itemGroup.y, itemGroup.width, itemGroup.height, true)
            //debugFlow.refresh();
        }
        onPositionChanged: {
            //TODO: height as well if it's going to become a grid view
            itemGroup.width = Math.max(itemGroup.minimumWidth, itemGroup.width + mouse.x-startX)
            if (itemGroup.canResizeHeight) {
                itemGroup.height = Math.max(itemGroup.minimumHeight, itemGroup.height + mouse.y-startY)
            }
        }
        onReleased: {
            animationsEnabled = true

            LayoutManager.positionItem(itemGroup)
            LayoutManager.save()
            LayoutManager.setSpaceAvailable(itemGroup.x, itemGroup.y, widthAnimation.to, heightAnimation.to, false)
            //debugFlow.refresh();
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
            text: itemGroup.title
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
            font.pointSize: theme.defaultFont.pointSize
            color: theme.textColor
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                topMargin: parent.margins.top
                leftMargin: height + 2
                rightMargin: height + 2
            }
        }
    }
}
