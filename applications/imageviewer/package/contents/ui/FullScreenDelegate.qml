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
import Qt.labs.gestures 1.0

Flickable {
    id: mainFlickable
    width: fullList.width
    height: fullList.height
    contentWidth: mainImage.width*mainImage.scale
    contentHeight: mainImage.height*mainImage.scale
    interactive: contentWidth > width || contentHeight > height
    property alias source: mainImage.source
    property string label: model["label"]

    NumberAnimation {
        id: zoomAnim
        duration: 250
        easing.type: Easing.InOutQuad
        target: mainImage
        property: "scale"
    }

    Connections {
        target: toolbar
        onZoomIn: {
            zoomAnim.to = mainImage.scale * 1.4
            zoomAnim.running = true
        }
        onZoomOut: {
            zoomAnim.to = mainImage.scale * 0.6
            zoomAnim.running = true
        }
    }

    Item {
        id: imageMargin
        width: Math.max(mainFlickable.width, mainImage.width*mainImage.scale)
        height: Math.max(mainFlickable.height, mainImage.height*mainImage.scale)
        clip: true
        GestureArea {
            anchors.fill: parent
            onPinch: {
                mainImage.scale = scaleFactor
            }
            Image {
                id: mainImage

                anchors.centerIn: parent
                Component.onCompleted: {
                    if (sourceSize.width < sourceSize.height) {
                        mainImage.scale = Math.min(1, mainFlickable.height/sourceSize.height)
                    } else {
                        mainImage.scale = Math.min(1, mainFlickable.width/sourceSize.width)
                    }
                }
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (imageViewer.state == "image") {
                        imageViewer.state = "image+toolbar"
                    } else {
                        imageViewer.state = "image"
                    }
                }
            }
        }
    }
}
