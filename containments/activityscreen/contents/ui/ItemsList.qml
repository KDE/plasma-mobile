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
import org.kde.plasma.components 0.1 as PlasmaComponents
import "plasmapackage:/code/LayoutManager.js" as LayoutManager
import org.kde.metadatamodels 0.1 as MetadataModels

Item {
    property alias count: itemsList.count
    anchors.fill: itemGroup.contents

    GridView {
        id: itemsList
        currentIndex: main.currentGroup==itemGroup?main.currentIndex:-1
        pressDelay: 200
        anchors.fill: parent
        snapMode: GridView.SnapToRow
        clip: true
        //spacing: 32;
        flow: GridView.TopToBottom 
        cellWidth: Math.floor(itemsList.width/Math.max(1, Math.floor(itemsList.width/140)))
        cellHeight: Math.floor(itemsList.height/Math.max(1, Math.floor(itemsList.height/120)))


        PropertyAnimation {
            id: scrollAnimation
            running: false
            target: itemsList
            properties: "contentX"
            duration: 250
        }

        model: PlasmaCore.SortFilterModel {
            sourceModel: MetadataModels.MetadataModel {
                activityId: plasmoid.activityId
                resourceType: itemGroup.category
                //sortBy is not used becauseitems that arrive after are put in the back
                //sortBy: [userTypes.sortFields[itemGroup.category]]
                //sortOrder: Qt.AscendingOrder
            }
            sortRole: "label"
        }

        highlight: PlasmaCore.FrameSvgItem {
                id: highlightFrame
                imagePath: "widgets/viewitem"
                prefix: "selected+hover"
        }

        delegate: Item {
            width: itemsList.cellWidth
            height: itemsList.cellHeight
            MobileComponents.ResourceDelegate {
                id: resourceDelegate
                width: 140
                height: itemsList.cellHeight
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }
                infoLabelVisible: false

                onPressAndHold: {
                    resourceInstance.uri = model["url"]?model["url"]:model["resourceUri"]
                    resourceInstance.title = model["label"]
                    main.currentIndex = index
                    main.currentGroup = itemGroup
                }

                onClicked: {
                    //Contact?
                    if (model["hasEmailAddress"]) {
                        plasmoid.openUrl(String(model["hasEmailAddress"]))
                    } else {
                        plasmoid.openUrl(String(model["url"]))
                    }
                }
            }
        }
    }

    PlasmaComponents.ScrollBar {
        flickableItem: itemsList
        orientation: Qt.Horizontal
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
        opacity: itemsList.atXBeginning?0:1
        enabled: !itemsList.atXBeginning
        Behavior on opacity {
            NumberAnimation {duration: 250}
        }
        MouseArea {
            anchors {
                fill: parent
                margins: -5
            }
            onClicked: {
                scrollAnimation.to = itemsList.contentX-itemsList.cellWidth
                scrollAnimation.running = true
            }
        }
    }

    PlasmaCore.SvgItem {
        anchors.right: itemsList.right
        anchors.verticalCenter: itemsList.verticalCenter
        width: 22
        height: 22
        svg: arrowsSvg
        elementId: "right-arrow"
        opacity: itemsList.atXEnd?0:1
        enabled: !itemsList.atXEnd
        Behavior on opacity {
            NumberAnimation {duration: 250}
        }
        MouseArea {
            anchors {
                fill: parent
                margins: -5
            }
            onClicked: {
                scrollAnimation.to = itemsList.contentX+itemsList.cellWidth
                scrollAnimation.running = true
            }
        }
    }
}
