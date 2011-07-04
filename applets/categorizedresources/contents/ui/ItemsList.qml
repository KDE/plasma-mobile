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


Item {
    property alias count: itemsList.count
    anchors {
        left: parent.left
        top: categoryTitle.bottom
        right: parent.right
        bottom: parent.bottom
        leftMargin: parent.margins.left
        rightMargin: parent.margins.right
        bottomMargin: parent.margins.bottom
    }

    ListView {
        id: itemsList
        currentIndex: main.currentGroup==itemGroup?main.currentIndex:-1
        pressDelay: 200
        anchors.fill: parent
        snapMode: ListView.SnapToItem
        clip: true
        spacing: 32;
        orientation: Qt.Horizontal

        model: MobileComponents.CategorizedProxyModel {
            sourceModel: metadataModel
            categoryRole: categoryListModel.categoryRole
            currentCategory: itemGroup.category
        }

        highlight: PlasmaCore.FrameSvgItem {
                id: highlightFrame
                imagePath: "widgets/viewitem"
                prefix: "selected+hover"
        }

        delegate: MobileComponents.ResourceDelegate {
            id: resourceDelegate
            width: 140
            height: itemsList.height
            resourceType: model.resourceType
            infoLabelVisible: false

            onPressed: {
                resourceInstance.uri = model["resourceUri"]
                main.currentIndex = index
                main.currentGroup = itemGroup
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
        anchors.left: itemsList.left
        anchors.verticalCenter: itemsList.verticalCenter
        width: 22
        height: 22
        svg: arrowsSvg
        elementId: "left-arrow"
        opacity: itemsList.atXBeginning?0.15:1
        Behavior on opacity {
            NumberAnimation {duration: 250}
        }
    }

    PlasmaCore.SvgItem {
        anchors.right: itemsList.right
        anchors.verticalCenter: itemsList.verticalCenter
        width: 22
        height: 22
        svg: arrowsSvg
        elementId: "right-arrow"
        opacity: itemsList.atXEnd?0.15:1
        Behavior on opacity {
            NumberAnimation {duration: 250}
        }
    }
}
