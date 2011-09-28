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

    ParallelAnimation {
        id: zoomAnim
        function zoom(factor)
        {
            if (factor < 1 && mainImage.scale < 0.2) {
                return
            } else if (factor > 1 && mainImage.scale > 8) {
                return
            }

            contentXAnim.to = Math.max(0, Math.min(mainFlickable.contentWidth-mainFlickable.width, (mainFlickable.contentX * factor)))
            contentYAnim.to = Math.max(0, Math.min(mainFlickable.contentHeight-mainFlickable.height, (mainFlickable.contentY * factor)))
            scaleAnim.to = mainImage.scale * factor
            zoomAnim.running = true
        }
        NumberAnimation {
            id: scaleAnim
            duration: 250
            easing.type: Easing.InOutQuad
            target: mainImage
            property: "scale"
        }
        NumberAnimation {
            id: contentXAnim
            duration: 250
            easing.type: Easing.InOutQuad
            target: mainFlickable
            property: "contentX"
        }
        NumberAnimation {
            id: contentYAnim
            duration: 250
            easing.type: Easing.InOutQuad
            target: mainFlickable
            property: "contentY"
        }
    }

    Connections {
        target: toolbar
        onZoomIn: {
            zoomAnim.zoom(1.4)
        }
        onZoomOut: {
            zoomAnim.zoom(0.6)
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

                asynchronous: true
                anchors.centerIn: parent
                onStatusChanged: {
                    if (status != Image.Ready) {
                        return
                    }

                    loadingText.visible = false
                    mainImage.scale = Math.min(1, mainFlickable.height/(scale*height))
                    mainImage.scale = Math.min(scale, Math.min(1, mainFlickable.width/(scale*width)))
 
                    if (mainImage.width > mainImage.height && mainImage.width > mainFlickable.width) {
                        mainImage.sourceSize.width = mainFlickable.width
                        mainImage.sourceSize.height = 0
                    }
                    if (mainImage.height > mainImage.width && mainImage.height > mainFlickable.height) {
                        mainImage.sourceSize.width = 0
                        mainImage.sourceSize.height = mainFlickable.height
                    }
                }
            }
            Text {
                id: loadingText
                font.pointSize: 18
                anchors.centerIn: mainImage
                text: i18n("Loading...")
                color: "gray"
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
