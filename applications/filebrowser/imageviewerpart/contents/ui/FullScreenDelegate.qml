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
import org.kde.plasma.extras 0.1 as PlasmaExtras
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents
import org.kde.qtextracomponents 0.1

Item {
    id: root
    //+1: switch to next image on mouse release
    //-1: switch to previous image on mouse release
    //0: do nothing
    property int delta
    //if true when released will switch the delegate
    property bool doSwitch: false

    property alias source: mainImage.source
    property string label: model["label"]

    SequentialAnimation {
        id: zoomAnim
        function zoom(factor)
        {
            if (factor < 1 &&
                (mainImage.width < mainFlickable.width &&
                 mainImage.height < mainFlickable.height)) {
                return
            } else if (factor > 1 &&
                (mainImage.width > mainFlickable.width*4 && 
                 mainImage.height > mainFlickable.height*4)) {
                return
            }

            contentXAnim.to = Math.max(0, Math.min(mainFlickable.contentWidth-mainFlickable.width, (mainFlickable.contentX * factor)))
            contentYAnim.to = Math.max(0, Math.min(mainFlickable.contentHeight-mainFlickable.height, (mainFlickable.contentY * factor)))
            imageWidthAnim.to = mainImage.width * factor
            imageHeightAnim.to = mainImage.height * factor
            zoomAnim.running = true
        }

        ParallelAnimation {
            NumberAnimation {
                id: imageWidthAnim
                duration: 250
                easing.type: Easing.InOutQuad
                target: mainImage
                property: "width"
            }
            NumberAnimation {
                id: imageHeightAnim
                duration: 250
                easing.type: Easing.InOutQuad
                target: mainImage
                property: "height"
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
        color: "black"
        width: mainFlickable.contentWidth
        height: parent.height
        x: -mainFlickable.contentX
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

    Flickable {
        id: mainFlickable
        anchors.fill: parent
        width: parent.width
        height: parent.height
        contentWidth: imageMargin.width
        contentHeight: imageMargin.height

        onContentXChanged: {
            if (atXBeginning && contentX < 0) {
                root.delta = -1
                root.doSwitch = (contentX < -theme.defaultFont.mSize.width * 10)
            } else if (atXEnd) {
                root.delta = +1
                root.doSwitch = (contentX + mainFlickable.width - contentWidth > theme.defaultFont.mSize.width * 10)
            } else {
                root.delta = 0
                root.doSwitch = false
            }
        }

        Item {
            id: imageMargin
            width: Math.max(mainFlickable.width+1, mainImage.width)
            height: Math.max(mainFlickable.height, mainImage.height)
            PinchArea {
                anchors.fill: parent

                property real startWidth
                property real startHeight
                property real startY
                property real startX
                onPinchStarted: {
                    if (mainImage.originalSourceSize != undefined && 
                            mainImage.sourceSize.height != mainImage.originalSourceSize.height && 
                            mainImage.sourceSize.width != mainImage.originalSourceSize.width) {
                        console.log("Restoring original sourceSize.")
                        console.log("Scaled width: " + mainImage.sourceSize.width + "; scaled height: " + mainImage.sourceSize.height)
                        mainImage.sourceSize = mainImage.originalSourceSize
                        console.log("Restored width: " + mainImage.sourceSize.width + "; restored height: " + mainImage.sourceSize.height)
                    }
                    startWidth = mainImage.width
                    startHeight = mainImage.height
                    startY = pinch.center.y
                    startX = pinch.center.x
                }
                onPinchUpdated: {
                    if (pinch.scale < 1 &&
                        (mainImage.width < Math.min(mainImage.sourceSize.width, mainFlickable.width) - 100 &&
                         mainImage.height < Math.min(mainImage.sourceSize.height, mainFlickable.height) - 100)) {
                        return
                    } else if (pinch.scale > 1 &&
                        (mainImage.width > mainFlickable.width*4 + 100 &&
                        mainImage.height > mainFlickable.height*4 + 100)) {
                        return
                    }

                    var deltaWidth = mainImage.width < imageMargin.width ? ((startWidth * pinch.scale) - mainImage.width) : 0
                    var deltaHeight = mainImage.height < imageMargin.height ? ((startHeight * pinch.scale) - mainImage.height) : 0
                    mainImage.width = startWidth * pinch.scale
                    mainImage.height = startHeight * pinch.scale

                    mainFlickable.contentY = Math.min(mainFlickable.contentHeight-mainFlickable.height, Math.max(0, mainFlickable.contentY + pinch.previousCenter.y - pinch.center.y + startY * (pinch.scale - pinch.previousScale) - deltaHeight))

                    mainFlickable.contentX = Math.min(mainFlickable.contentWidth-mainFlickable.width, Math.max(0, mainFlickable.contentX + pinch.previousCenter.x - pinch.center.x + startX * (pinch.scale - pinch.previousScale) - deltaWidth))
                }

                onPinchFinished: {
                    if (mainImage.width < mainFlickable.width &&
                        mainImage.height < mainFlickable.height) {

                        if (mainImage.sourceSize.width < mainFlickable.width &&
                            mainImage.sourceSize.height < mainFlickable.height) {
                            if (mainImage.width > mainImage.height) {
                                zoomAnim.zoom(mainImage.sourceSize.width/mainImage.width)
                            } else {
                                zoomAnim.zoom(mainImage.sourceSize.height/mainImage.height)
                            }
                        } else {
                            if (mainImage.width > mainImage.height) {
                                zoomAnim.zoom(mainFlickable.width/mainImage.width)
                            } else {
                                zoomAnim.zoom(mainFlickable.height/mainImage.height)
                            }
                        }

                    } else if (mainImage.width > mainFlickable.width*4 && 
                        mainImage.height > mainFlickable.height*4) {
                        if (mainImage.width > mainImage.height) {
                            zoomAnim.zoom(mainFlickable.width*4/mainImage.width)
                        } else {
                            zoomAnim.zoom(mainFlickable.height*4/mainImage.height)
                        }
                    }
                }

                Image {
                    id: mainImage

                    property variant originalSourceSize
                    asynchronous: true
                    anchors.centerIn: parent
                    fillMode: Image.PreserveAspectFit
                    width: mainFlickable.contentWidth
                    height: mainFlickable.contentHeight

                    onSourceChanged: {
                        originalSourceSize = undefined
                    }

                    onStatusChanged: {
                        if (status != Image.Ready || originalSourceSize != undefined) {
                            return
                        }

                        loadingText.visible = false

                        // do not try to load an empty mainImage.source or it will mess up with mainImage.scale
                        // and make the next valid url fail to load.
                        if (mainFlickable.parent.width < 1 || mainFlickable.parent.height < 1) {
                            return
                        }

                        if (mainImage.sourceSize.width > mainFlickable.width || mainImage.sourceSize.height > mainFlickable.height) {
                            console.log("Image will be shrinked. Storing original size such that it can be resized back.")
                            console.log("Original width: " + sourceSize.width + "; original height: " + sourceSize.height)
                            originalSourceSize = sourceSize
                        }

                        var ratio = sourceSize.width/sourceSize.height
                        if (sourceSize.width > sourceSize.height) {
                            mainImage.width = Math.min(mainFlickable.width, sourceSize.width)
                            mainImage.height = mainImage.width / ratio
                        } else {
                            mainImage.height = Math.min(mainFlickable.height, sourceSize.height)
                            mainImage.width = mainImage.height * ratio
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

                PlasmaExtras.Title {
                    id: loadingText
                    anchors.centerIn: mainImage
                    text: i18n("Loading...")
                    color: "gray"
                }
            }
        }
    }
}
