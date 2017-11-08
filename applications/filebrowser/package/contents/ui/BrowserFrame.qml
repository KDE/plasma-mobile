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

import QtQuick 2.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.mobilecomponents 0.2 as MobileComponents
import org.kde.kquickcontrolsaddons 2.0
import org.kde.plasma.private.folder 0.1 as Folder
import org.kde.draganddrop 2.0

Item {
    id: browserFrame
    anchors.fill: parent
    property url resourceInstance

    ListModel {
        id: selectedModel
        signal modelCleared
    }

    Folder.Positioner {
        id: positioner
        folderModel: folderModel
    }

    Folder.ItemViewAdapter {
        id: viewAdapter
        adapterView: resultsGrid
        adapterModel: positioner

        Component.onCompleted: {
            folderModel.sourceModel.viewAdapter = viewAdapter;
        }
    }

    Connections {
        target: resultsGrid
        onCountChanged: {
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

                thumbnails[i] = selectedModel.get(i).decoration
                labels[i] = selectedModel.get(i).display
                mimeTypes[i] = selectedModel.get(i).resourceType
            }
            dragArea.mimeData.urls = newUrls
            dragArea.mimeTypes = mimeTypes
            dragArea.thumbnails = thumbnails
            dragArea.labels = labels
        }
    }
    Connections {
        target: balooDataModel.sourceModel
        onQueryChanged: selectedModel.clear()
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
                    ResourceDelegate {
                        resourceType: dragArea.mimeTypes[index]
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
                property int startY: 0
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
                    delegateWidth: Math.floor(resultsGrid.width / Math.max(Math.floor(resultsGrid.width / (units.gridUnit*12)), 3))
                    delegateHeight: delegateWidth / 1.6
                    anchors.fill: parent
                    clip: false

                    model: fileBrowserRoot.model == folderModel ? positioner : fileBrowserRoot.model
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
                            property real delegateX: resourceDelegate.x + resourceDelegate.parent.parent.x - resultsGrid.contentX
                            property real delegateY: resourceDelegate.y

                            property bool contains: delegateX+resourceDelegate.width > selectionRect.x && delegateY+resourceDelegate.height > selectionRect.y && delegateX < selectionRect.x+selectionRect.width && delegateY < selectionRect.y+selectionRect.height
                            opacity: 0
                            /*Behavior on opacity {
                                NumberAnimation {duration: 250}
                            }*/
                            onContainsChanged: {
                                if (contains) {
                                    selectedModel.append(model)
                                    opacity = 1
                                    if (selectedModel.count == 1) {
                                        resourceInstance = model.url;
                                    } else {
                                        resourceInstance = "";
                                    }
                                } else {
                                    if (resourceInstance === model.url) {
                                        resourceInstance = "";
                                    }
                                    for (var i = 0; i < selectedModel.count; ++i) {
                                        if ((model.url && model.url == selectedModel.get(i).url)) {
                                            opacity = 0
                                            selectedModel.remove(i)
                                            if (selectedModel.count == 1) {
                                                resourceInstance = selectedModel.get(0).url;
                                            }
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
                        ResourceDelegate {
                            anchors.fill: parent
                            resourceType: {
                                if (fileBrowserRoot.model.sourceModel.query  !== undefined) {
                                    var type =resultsGrid.model.sourceModel.query.type
                                    type = type.replace("File/", "")
                                    return type
                                } else if (model.resourceType !== undefined){
                                    return model.resourceType
                                } else {
                                    return "FileDataObject"
                                }
                            }

                            width: resultsGrid.delegateWidth
                            height: resultsGrid.delegateHeight
                            onPressed: {
                                if (selectedModel.count > 0 &&
                                    highlightFrame.opacity > 0) {
                                    dragArea.enabled = true
                                }
                            }
                            onPressAndHold: highlightFrame.contains = !highlightFrame.contains

                            onClicked: {
                                openResource(model)
                            }
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


