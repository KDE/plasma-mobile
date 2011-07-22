/*
 *   Copyright 2011 Marco Martin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
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
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents
import org.kde.qtextracomponents 0.1

Rectangle {
    id: imageViewer
    objectName: "imageViewer"
    color: "#ddd"

    width: 360
    height: 360

    PlasmaCore.DataSource {
        id: metadataSource
        engine: "org.kde.active.metadata"
        connectedSources: ["ResourcesOfType:Image"]
        interval: 0
    }
    PlasmaCore.DataModel {
        id: metadataModel
        keyRoleFilter: ".*"
        dataSource: metadataSource
    }

    MobileComponents.IconGrid {
        id: resultsGrid
        anchors {
            fill: parent
        }

        Component.onCompleted: resultsContainer.contentY = resultsContainer.height
        height: resultsContainer.height
        model: metadataModel
        delegate: MobileComponents.ResourceDelegate {
            id: resourceDelegate
            width: 130
            height: 120
            infoLabelVisible: false

            onClicked: {
                mainImage.source = model["url"]
                viewer.visible = true
            }
        }
    }

    Rectangle {
        id: viewer
        visible: startupArguments[0].length > 0
        color: "#ddd"
        anchors {
            fill:  parent
        }
        Flickable {
            anchors {
                fill:  parent
            }
            contentWidth: imageMargin.width
            contentHeight: imageMargin.height
            interactive:  true
            Item {
                id: imageMargin
                width: Math.max(viewer.width, mainImage.width)
                height: Math.max(viewer.height, mainImage.height)
                Image {
                    id: mainImage
                    objectName: "mainImage"
                    source: startupArguments[0]
                    anchors.centerIn: parent
                }
            }
        }
    }

    QIconItem {
        icon: QIcon("go-previous")
        width: 48
        height: 48
        opacity: viewer.visible?1:0
        Behavior on opacity {
            NumberAnimation {
                duration: 250
                easing.type: Easing.InOutQuad
            }
        }
        MouseArea {
            anchors.fill: parent
            onClicked: viewer.visible = false
        }
    }
}
