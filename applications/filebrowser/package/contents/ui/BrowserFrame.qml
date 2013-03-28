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
import org.kde.metadatamodels 0.1 as MetadataModels
import org.kde.plasma.components 0.1 as PlasmaComponents
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents
import org.kde.draganddrop 1.0
import org.kde.qtextracomponents 0.1


Item {
    id: browserFrame
    anchors.fill: parent


    //FIXME: this will have to be removed
    Timer {
        interval: 100
        running: true
        onTriggered: backConnection.target = application.action("back")
    }
    Connections {
        id: backConnection
        target: application.action("back")
        onTriggered: {
            resourceInstance.uri = ""
            fileBrowserRoot.goBack()
        }
    }

    ListModel {
        id: selectedModel
        signal modelCleared
    }

    Connections {
        target: metadataModel
        onModelReset: {
            selectedModel.clear()
            selectedModel.modelCleared()
        }
    }

    //BUG: For some reason onCountChanged doesn't get binded directly in ListModel
    Connections {
        target: selectedModel
        onCountChanged: {
            var thumbnails = new Array()
            var labels = new Array()
            var mimeTypes = new Array()

            var newUrls = new Array()
            for (var i = 0; i < selectedModel.count; ++i) {
                newUrls[i] = selectedModel.get(i).url

                thumbnails[i] = selectedModel.get(i).thumbnail
                labels[i] = selectedModel.get(i).label
                mimeTypes[i] = selectedModel.get(i).mimeType
            }
            dragArea.mimeData.urls = newUrls
            dragArea.mimeTypes = mimeTypes
            dragArea.thumbnails = thumbnails
            dragArea.labels = labels
        }
    }
    Connections {
        target: metadataModel
        onModelReset: selectedModel.clear()
    }

    //This pinch area is for selection
    PinchArea {
        id: pinchArea
        anchors {
            fill: parent
            leftMargin: 0
        }
        property bool selecting: false
        property int selectingX
        property int selectingY
        pinch.target: parent

        function resetSelection()
        {
            selectedModel.modelCleared()
            selectedModel.clear()
            selectionRect.x = -1
            selectionRect.y = -1
            selectionRect.width = 0
            selectionRect.height = 0
        }

        onPinchStarted: {
            //hotspot to start select procedures
            print("point1: " + pinch.point1.x + " " + pinch.point1.y)
            print("Selecting")
            selecting = true
            selectingX = pinch.point2.x
            selectingY = pinch.point2.y
            selectionRect.opacity = 0.4
        }
        onPinchUpdated: {
            //only one point
            if (pinch.point1.x == pinch.point2.x) {
                return
            }
            selectionRect.x = Math.min(pinch.point1.x, pinch.point2.x)
            selectionRect.y = Math.min(pinch.point1.y, pinch.point2.y)
            selectionRect.width = Math.abs(pinch.point2.x - pinch.point1.x)
            selectionRect.height = Math.abs(pinch.point2.y - pinch.point1.y)
            if (selecting) {
                print("Selected" + resultsGrid.childAt(pinch.point2.x, pinch.point2.y))
                selectingX = pinch.point2.x
                selectingY = pinch.point2.y
            }
        }
        onPinchFinished: {
            selectionRect.opacity = 0
            selecting = false
        }

        Rectangle {
            id: selectionRect
            color: theme.highlightColor
            opacity: 0.4
            Behavior on opacity {
                NumberAnimation {
                    duration: 250
                    easing.type: Easing.InOutQuad
                }
            }
        }
        DragArea {
            id: dragArea
            anchors.fill: parent
            property variant labels
            property variant thumbnails
            property variant mimeTypes
            //startDragDistance: 200
            enabled: false
            mimeData {
                source: parent
            }
            onDrop: enabled = false
            delegate: Item {
                width: 250
                height: 250
                opacity: 0.7

                Repeater {
                    model: Math.min(4, dragArea.labels.length)
                    MobileComponents.ResourceDelegate {
                        className: mimeType.indexOf("image") !== -1 ? "Image" : "FileDataObject"
                        property string mimeType: dragArea.mimeTypes[index]
                        property string label: dragArea.labels.length == 1 ? dragArea.labels[index] : ""
                        property variant thumbnail: dragArea.thumbnails[index]

                        anchors.centerIn: parent
                        width: 200
                        height: 200/1.6
                        transformOrigin: Item.Bottom
                        rotation: (dragArea.labels.length > 1 ? 20 : 0) -20*index
                        z: -index
                        smooth: true
                    }
                }
            }
            MouseEventListener {
                anchors.fill: parent
                onPressed: startY = mouse.y

                onPositionChanged: {
                    if (selectedModel.count > 0 && Math.abs(mouse.y - startY) > 100) {
                        dragArea.enabled = true
                    }
                }

                onReleased: {
                    //are we outside the listview area?
                    if (resultsGrid.childAt(mouse.x, mouse.y).delegate === undefined && selectionRect.width == 0) {
                        selectedModel.clear()
                        selectedModel.modelCleared()
                    }
                    dragArea.enabled = false
                }
                Connections {
                    target: fileBrowserRoot.model
                    onCountChanged: pinchArea.resetSelection()
                    onModelReset: pinchArea.resetSelection()
                }
                MobileComponents.IconGrid {
                    id: resultsGrid
                    anchors.fill: parent
                    clip: false

                    model: fileBrowserRoot.model
                    onCurrentPageChanged: pinchArea.resetSelection()

                    delegate: Item {
                        id: resourceDelegate
                        width: resultsGrid.delegateWidth
                        height: resultsGrid.delegateHeight

                        PlasmaCore.FrameSvgItem {
                            id: highlightFrame
                            imagePath: "widgets/viewitem"
                            prefix: "selected+hover"
                            anchors.fill: parent
                            property real delegateX: resultsGrid.mapFromItem(resourceDelegate, 0, 0).x
                            property real delegateY: resultsGrid.mapFromItem(resourceDelegate, 0, 0).y

                            property bool contains: delegateX+resourceDelegate.width > selectionRect.x && delegateY+resourceDelegate.height > selectionRect.y && delegateX < selectionRect.x+selectionRect.width && delegateY < selectionRect.y+selectionRect.height
                            opacity: 0
                            /*Behavior on opacity {
                                NumberAnimation {duration: 250}
                            }*/
                            onContainsChanged: {
                                if (contains) {
                                    selectedModel.append(model)
                                    opacity = 1
                                } else {
                                    for (var i = 0; i < selectedModel.count; ++i) {
                                        if ((model.url && model.url == selectedModel.get(i).url)) {
                                            opacity = 0
                                            selectedModel.remove(i)
                                            return
                                        }
                                    }
                                }
                            }
                        }
                        Connections {
                            target: selectedModel
                            onModelCleared: highlightFrame.opacity = 0
                        }
                        MobileComponents.ResourceDelegate {
                            className: model["className"] ? model["className"] : ""
                            genericClassName: (resultsGrid.model == metadataModel) ? (model["genericClassName"] ? model["genericClassName"] : "") : "FileDataObject"

                            property string label: model.label ? model.label : model.display

                            width: resultsGrid.delegateWidth
                            height: resultsGrid.delegateHeight
                            onPressed: {
                                if (selectedModel.count > 0 && 
                                    highlightFrame.opacity > 0) {
                                    dragArea.enabled = true
                                }
                            }
                            onPressAndHold: highlightFrame.contains = !highlightFrame.contains

                            onClicked: openResource(model)
                        }
                        Component.onCompleted: {
                            for (var i = 0; i < selectedModel.count; ++i) {
                                if ((model.url && model.url == selectedModel.get(i).url)) {
                                    highlightFrame.opacity = 1
                                    return
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}


