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
    property string name: modelData
    imagePath: "widgets/background"
    width: Math.min(470, 32+webItemList.count*140)
    height: 150
    z: 0
    property bool animationsEnabled: false

    MouseArea {
        anchors.fill: parent
        drag.target: parent
        onPressed: {
            animationsEnabled = false
            mouse.accepted = true
            var x = Math.round(parent.x/LayoutManager.cellSize.width)*LayoutManager.cellSize.width
            var y = Math.round(parent.y/LayoutManager.cellSize.height)*LayoutManager.cellSize.height
            LayoutManager.setSpaceAvailable(x, y, parent.width, parent.height, true)

            debugFlow.refresh();
        }
        onReleased: {
            animationsEnabled = true
            LayoutManager.positionItem(parent)
            debugFlow.refresh()
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

            LayoutManager.positionItem(parent)
            LayoutManager.setSpaceAvailable(itemGroup.x, itemGroup.y, widthAnimation.to, itemGroup.height, false)
            debugFlow.refresh();
        }
    }
    Component.onCompleted: {
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
            text: i18n("%1 (%2)", modelData, webItemList.count)
            anchors {
                top: parent.top
                horizontalCenter: parent.horizontalCenter
                topMargin: parent.margins.top
            }
        }
    }

    ListView {
        id: webItemList
        anchors {
            left: parent.left
            top: categoryTitle.bottom
            right: parent.right
            bottom: parent.bottom
            leftMargin: parent.margins.left
            rightMargin: parent.margins.right
            bottomMargin: parent.margins.bottom
        }
        snapMode: ListView.SnapToItem
        clip: true
        spacing: 32;
        orientation: Qt.Horizontal

        model: MobileComponents.CategorizedProxyModel {
            sourceModel: metadataModel
            categoryRole: "className"
            currentCategory: modelData
        }

        highlight: PlasmaCore.FrameSvgItem {
                id: highlightFrame
                imagePath: "widgets/viewitem"
                prefix: "selected+hover"
        }

        delegate: MobileComponents.ResourceDelegate {
            id: resourceDelegate
            width: 140
            height: webItemList.height
            resourceType: model.resourceType
            infoLabelVisible: false

            onPressed: {
                resourceInstance.uri = model["url"]
            }

            onClicked: {
                plasmoid.openUrl(String(model["url"]))
            }

        }
    }

    PlasmaCore.Svg {
        id: arrowsSvg
        imagePath: "widgets/arrows"
    }

    PlasmaCore.SvgItem {
        anchors.left: webItemList.left
        anchors.verticalCenter: webItemList.verticalCenter
        width: 22
        height: 22
        svg: arrowsSvg
        elementId: "left-arrow"
        opacity: webItemList.atXBeginning?0.15:1
        Behavior on opacity {
            NumberAnimation {duration: 250}
        }
    }

    PlasmaCore.SvgItem {
        anchors.right: webItemList.right
        anchors.verticalCenter: webItemList.verticalCenter
        width: 22
        height: 22
        svg: arrowsSvg
        elementId: "right-arrow"
        opacity: webItemList.atXEnd?0.15:1
        Behavior on opacity {
            NumberAnimation {duration: 250}
        }
    }
}
