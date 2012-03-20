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
 *   GNU Library General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 1.1
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents
import org.kde.qtextracomponents 0.1

Flickable {
    id: mainFlickable
    width: parent.width
    height: parent.height
    contentWidth: mainImage.width
    contentHeight: mainImage.height
    onContentHeightChanged: interactiveTimer.restart()
    property alias source: mainImage.source
    property string label: model["label"]

    //defer interactive decision; set interactive when disabled: it will make it spit out an eventual mouse grabber
    Timer {
        id: interactiveTimer
        interval: 200
        repeat: false
        running: true
        onTriggered: {
            mainFlickable.enabled = false
            mainFlickable.interactive = contentWidth > width || contentHeight > height
            mainFlickable.enabled = true
        }
    }

    SequentialAnimation {
        id: zoomAnim
        function zoom(factor)
        {
            if (factor < 1 && mainFlickable.contentWidth < mainFlickable.width && mainFlickable.contentHeight < mainFlickable.height) {
                return
            } else if (factor > 1 && (mainFlickable.contentWidth > mainFlickable.width*8 && mainFlickable.contentHeight > mainFlickable.height*8)) {
                return
            }

            contentXAnim.to = Math.max(0, Math.min(mainFlickable.contentWidth-mainFlickable.width, (mainFlickable.contentX * factor)))
            contentYAnim.to = Math.max(0, Math.min(mainFlickable.contentHeight-mainFlickable.height, (mainFlickable.contentY * factor)))
            contentWidthAnim.to = mainFlickable.contentWidth * factor
            contentHeightAnim.to = mainFlickable.contentHeight * factor
            zoomAnim.running = true
        }

        ParallelAnimation {
            NumberAnimation {
                id: contentWidthAnim
                duration: 250
                easing.type: Easing.InOutQuad
                target: mainFlickable
                property: "contentWidth"
            }
            NumberAnimation {
                id: contentHeightAnim
                duration: 250
                easing.type: Easing.InOutQuad
                target: mainFlickable
                property: "contentHeight"
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
        ScriptAction {
            script: mainFlickable.returnToBounds()
        }
    }

    Connections {
        target: viewerPage
        onZoomIn: {
            zoomAnim.zoom(1.4)
        }
        onZoomOut: {
            zoomAnim.zoom(0.6)
        }
    }

    Rectangle {
        id: imageMargin
        color: "black"
        width: Math.max(mainFlickable.width, mainImage.width)
        height: Math.max(mainFlickable.height, mainImage.height)
        PinchArea {
            anchors.fill: parent
            property real initialWidth
            property real initialHeight
            onPinchStarted: {
                initialWidth = contentWidth
                initialHeight = contentHeight
             }
            onPinchUpdated: {
                contentX += pinch.previousCenter.x - pinch.center.x
                contentY += pinch.previousCenter.y - pinch.center.y
                
                // resize content
                mainFlickable.resizeContent(initialWidth * pinch.scale, initialHeight * pinch.scale, Qt.point(pinch.center.x-mainImage.x, pinch.center.y-mainImage.y))
            }

            Image {
                id: mainImage

                asynchronous: true
                anchors.centerIn: parent
                width: mainFlickable.contentWidth
                height: mainFlickable.contentHeight
                onStatusChanged: {
                    if (status != Image.Ready) {
                        return
                    }

                    loadingText.visible = false

                    // do not try to load an empty mainImage.source or it will mess up with mainImage.scale
                    // and make the next valid url fail to load.
                    if (mainFlickable.parent.width < 1 || mainFlickable.parent.height < 1) {
                        return
                    }

                    var ratio = sourceSize.width/sourceSize.height
                    if (sourceSize.width > sourceSize.height) {
                        mainFlickable.contentWidth = Math.min(mainFlickable.width, sourceSize.width)
                        mainFlickable.contentHeight = mainFlickable.contentWidth / ratio
                    } else {
                        mainFlickable.contentHeight = Math.min(mainFlickable.height, sourceSize.height)
                        mainFlickable.contentWidth = mainFlickable.contentHeight * ratio
                    }
 
                    if (mainImage.sourceSize.width > mainImage.sourceSize.height && mainImage.sourceSize.width > mainFlickable.width) {
                        mainImage.sourceSize.width = mainFlickable.width
                        mainImage.sourceSize.height = mainImage.sourceSize.width / ratio
                    } else if (mainImage.sourceSize.height > mainImage.sourceSize.width && mainImage.sourceSize.height > mainFlickable.height) {
                        mainImage.sourceSize.width = mainFlickable.height * ratio
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
        }
        Image {
            z: -1
            source: "image://appbackgrounds/shadow-left"
            fillMode: Image.TileVertically
            anchors {
                right: parent.left
                top: parent.top
                bottom: parent.bottom
                rightMargin: -1
            }
        }
        Image {
            z: -1
            source: "image://appbackgrounds/shadow-right"
            fillMode: Image.TileVertically
            anchors {
                left: parent.right
                top: parent.top
                bottom: parent.bottom
                leftMargin: -1
            }
        }
    }
}
