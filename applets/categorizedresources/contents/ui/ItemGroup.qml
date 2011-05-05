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

PlasmaCore.FrameSvgItem {
    imagePath: "dialogs/background"
    width: Math.min(470, 64+webItemList.count*200)
    height: 190

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
            text: modelData
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
        spacing: 8;
        orientation: Qt.Horizontal

        model: MobileComponents.CategorizedProxyModel {
            sourceModel: metadataModel
            categoryRole: "className"
            currentCategory: modelData
        }

        delegate: MobileComponents.ResourceDelegate {
            width: 250
            height: 64
            resourceType: model.resourceType
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    plasmoid.openUrl(String(url))
                }
                onPressAndHold: {
                    var menuPos = parent.mapToItem(main, 0, 0)
                    contextMenu.x = menuPos.x
                    contextMenu.y = menuPos.y
                    contextMenu.visible = true
                }
                onReleased: {
                    contextMenu.visible = false
                }
            }
        }
    }
}
