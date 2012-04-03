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
import org.kde.plasma.slccomponents 0.1 as SlcComponents
import org.kde.draganddrop 1.0
import org.kde.qtextracomponents 0.1
import org.kde.dirmodel 0.1


PlasmaComponents.Page {
    anchors {
        fill: parent
        topMargin: toolBar.height
    }

    tools: Item {
        width: parent.width
        height: childrenRect.height

        PlasmaCore.DataSource {
            id: hotplugSource
            engine: "hotplug"
            connectedSources: sources
        }
        PlasmaCore.DataSource {
            id: devicesSource
            engine: "soliddevice"
            connectedSources: hotplugSource.sources
            onDataChanged: {
                //access it here due to the async nature of the dataengine
                if (resultsGrid.model != dirModel && devicesSource.data[devicesTabBar.currentUdi]["File Path"] != "") {
                    dirModel.url = devicesSource.data[devicesTabBar.currentUdi]["File Path"]

                    resultsGrid.model = dirModel
                }
            }
        }
        PlasmaCore.DataModel {
            id: devicesModel
            dataSource: hotplugSource
        }
        DirModel {
            id: dirModel
            onUrlChanged: {
                breadCrumb.path = url.substr(devicesSource.data[devicesTabBar.currentUdi]["File Path"].length)
            }
        }

        Breadcrumb {
            id: breadCrumb

            onPathChanged: {
                dirModel.url = devicesSource.data[devicesTabBar.currentUdi]["File Path"] + path
            }
            anchors {
                left: parent.left
                right: searchBox.left
                verticalCenter: parent.verticalCenter
                leftMargin: y
            }
        }
        PlasmaComponents.TabBar {
            id: devicesTabBar
            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
                rightMargin: y
            }
            height: theme.largeIconSize
            width: height * tabCount
            property int tabCount: 1
            property string currentUdi

            function updateSize()
            {
                var visibleChildCount = devicesTabBar.layout.children.length

                for (var i = 0; i < devicesTabBar.layout.children.length; ++i) {
                    if (!devicesTabBar.layout.children[i].visible || devicesTabBar.layout.children[i].text === undefined) {
                        --visibleChildCount
                    }
                }
                devicesTabBar.tabCount = visibleChildCount
            }

            opacity: tabCount > 1 ? 1 : 0
            Behavior on opacity {
                NumberAnimation {
                    duration: 250
                    easing.type: Easing.InOutQuad
                }
            }
            PlasmaComponents.TabButton {
                id: localButton
                height: width
                property bool current: devicesTabBar.currentTab == localButton
                iconSource: "drive-harddisk"
                onCurrentChanged: {
                    if (current) {
                        resultsGrid.model = metadataModel
                        //nepomuk db, not filesystem
                        devicesTabBar.currentUdi = ""
                    }
                }
            }

            Repeater {
                id: devicesRepeater
                model: devicesModel
                onCountChanged: devicesTabBar.updateSize()

                delegate: PlasmaComponents.TabButton {
                    id: removableButton
                    visible: devicesSource.data[udi]["Removable"] == true
                    onVisibleChanged: devicesTabBar.updateSize()
                    iconSource: model["icon"]
                    property bool current: devicesTabBar.currentTab == removableButton
                    onCurrentChanged: {
                        if (current) {
                            devicesTabBar.currentUdi = udi

                            if (devicesSource.data[udi]["Accessible"]) {
                                dirModel.url = devicesSource.data[devicesTabBar.currentUdi]["File Path"]

                                resultsGrid.model = dirModel
                            } else {
                                var service = devicesSource.serviceForSource(udi);
                                var operation = service.operationDescription("mount");
                                service.startOperationCall(operation);
                            }
                        }
                    }
                }
            }
        }

        MobileComponents.ViewSearch {
            id: searchBox
            anchors.centerIn: parent

            onSearchQueryChanged: {
                metadataModel.extraParameters["nfo:fileName"] = searchBox.searchQuery
                busy = (searchBox.searchQuery.length > 0)
            }
        }
    }

    ListModel {
        id: selectedModel
    }
    //For some reason onCountChanged doesn't get binded directly in ListModel
    Connections {
        target: selectedModel
        onCountChanged: {
            var newUrls = new Array()
            for (var i = 0; i < selectedModel.count; ++i) {
              newUrls[i] = selectedModel.get(i).url
            }
            dragArea.mimeData.urls = newUrls
        }
    }
    Connections {
        target: metadataModel
        onModelReset: selectedModel.clear()
        onCountChanged: { searchBox.restartBusyTimer() }
    }

    //This pinch area is for selection
    PinchArea {
        id: pinchArea
        property bool selecting: false
        property int selectingX
        property int selectingY
        pinch.target: parent
        onPinchStarted: {
            //hotspot to start select procedures
            print("point1: " + pinch.point1.x + " " + pinch.point1.y)
            print("Selecting")
            selecting = true
            selectingX = pinch.point2.x
            selectingY = pinch.point2.y
        }
        onPinchUpdated: {
            if (selecting) {
                print("Selected" + resultsGrid.childAt(pinch.point2.x, pinch.point2.y))
                selectingX = pinch.point2.x
                selectingY = pinch.point2.y
            }
        }
        onPinchFinished: selecting = false
        anchors.fill: parent
        DragArea {
            id: dragArea
            anchors.fill: parent
            //startDragDistance: 200
            enabled: false
            mimeData {
                source: parent
            }
            onDrop: enabled = false
            MouseEventListener {
                anchors.fill: parent
                onPressed: startY = mouse.y
                onPositionChanged: {
                    if (selectedModel.count > 0 && Math.abs(mouse.y - startY) > 200) {
                        parent.enabled = true
                    }
                }
                MobileComponents.IconGrid {
                    id: resultsGrid
                    anchors.fill: parent

                    model: metadataModel

                    delegate: Item {
                        id: resourceDelegate
                        width: resultsGrid.delegateWidth
                        height: resultsGrid.delegateHeight

                        PlasmaCore.FrameSvgItem {
                            id: highlightFrame
                            imagePath: "widgets/viewitem"
                            prefix: "selected+hover"
                            anchors.fill: parent

                            property bool contains: (pinchArea.selectingX > resourceDelegate.x && pinchArea.selectingX < resourceDelegate.x + resourceDelegate.width) && (pinchArea.selectingY > resourceDelegate.y && pinchArea.selectingY < resourceDelegate.y + resourceDelegate.height)
                            opacity: 0
                            Behavior on opacity {
                                NumberAnimation {duration: 250}
                            }
                            onContainsChanged: {
                                if (contains) {
                                    for (var i = 0; i < selectedModel.count; ++i) {
                                        if ((model.url && model.url == selectedModel.get(i).url)) {
                                            opacity = 0
                                            selectedModel.remove(i)
                                            return
                                        }
                                    }

                                    selectedModel.append({"url": model.url})
                                    opacity = 1
                                }
                            }
                        }
                        MobileComponents.ResourceDelegate {
                            className: model["className"] ? model["className"] : ""
                            genericClassName: (resultsGrid.model == metadataModel) ? (model["genericClassName"] ? model["genericClassName"] : "") : "FileDataObject"

                            width: resultsGrid.delegateWidth
                            height: resultsGrid.delegateHeight
                            infoLabelVisible: false
                            onClicked: Qt.openUrlExternally(model.url)
                        }
                    }
                }
            }
        }
    }
    ParallelAnimation {
        id: positionAnim
        property Item target
        property int x
        property int y
        NumberAnimation {
            target: positionAnim.target
            to: positionAnim.y
            properties: "y"

            duration: 250
            easing.type: Easing.InOutQuad
        }
        NumberAnimation {
            target: positionAnim.target
            to: positionAnim.x
            properties: "x"

            duration: 250
            easing.type: Easing.InOutQuad
        }
    }
}

