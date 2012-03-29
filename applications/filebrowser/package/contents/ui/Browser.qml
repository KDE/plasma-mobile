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


PlasmaComponents.Page {
    id: resourceBrowser
    objectName: "resourceBrowser"
    property string currentUdi
    anchors {
        fill: parent
        topMargin: toolBar.height
    }

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
            if (resultsGrid.model != dirModel && devicesSource.data[resourceBrowser.currentUdi]["File Path"] != "") {
                dirModel.url = devicesSource.data[resourceBrowser.currentUdi]["File Path"]

                fileBrowserRoot.model = dirModel
            }
        }
    }

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

    tools: Item {
        width: parent.width
        height: childrenRect.height

        PlasmaCore.DataModel {
            id: devicesModel
            dataSource: hotplugSource
        }

        Breadcrumb {
            id: breadCrumb

            path: dirModel.url.substr(devicesSource.data[resourceBrowser.currentUdi]["File Path"].length + String("file://").length)
            anchors {
                left: parent.left
                right: searchBox.left
                verticalCenter: parent.verticalCenter
                leftMargin: y
            }
        }

        MobileComponents.ViewSearch {
            id: searchBox
            anchors.centerIn: parent

            onSearchQueryChanged: {
                metadataModel.extraParameters["nfo:fileName"] = searchBox.searchQuery
            }
        }

        Item {
            width: childrenRect.width
            height: childrenRect.height
            clip: true
            anchors {
                right: emptyTrashButton.left
                bottom: parent.bottom
                bottomMargin: -8
                rightMargin: 4
            }
            PlasmaComponents.ButtonRow {
                z: 900
                y: sidebar.open ? 0 : height
                Behavior on y {
                    NumberAnimation {
                        duration: 250
                        easing.type: Easing.InOutQuad
                    }
                }
                SidebarTab {
                    id: mainTab
                    text: i18n("Tools")
                    onCheckedChanged: {
                        if (checked) {
                            while (sidebarStack.depth > 1) {
                                sidebarStack.pop()
                            }
                        }
                    }
                }
                SidebarTab {
                    text: i18n("Time")
                    enabled: fileBrowserRoot.model == metadataModel
                    opacity: enabled ? 1 : 0.6
                    onCheckedChanged: {
                        if (checked) {
                            if (sidebarStack.depth > 1) {
                                sidebarStack.replace(Qt.createComponent("TimelineSidebar.qml"))
                            } else {
                                sidebarStack.push(Qt.createComponent("TimelineSidebar.qml"))
                            }
                        }
                    }
                }
                SidebarTab {
                    text: i18n("Tags")
                    enabled: fileBrowserRoot.model == metadataModel
                    opacity: enabled ? 1 : 0.6
                    onCheckedChanged: {
                        print(checked)
                        if (checked) {
                            if (sidebarStack.depth > 1) {
                                sidebarStack.replace(Qt.createComponent("TagsBar.qml"))
                            } else {
                                sidebarStack.push(Qt.createComponent("TagsBar.qml"))
                            }
                        }
                    }
                }
            }
        }

        PlasmaComponents.ToolButton {
            id: emptyTrashButton
            width: theme.largeIconSize
            height: width
            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
                rightMargin: y
            }
            visible: fileBrowserRoot.model == dirModel && dirModel.url == "trash:/"
            enabled: dirModel.count > 0
            iconSource: "trash-empty"
            onClicked: application.emptyTrash()
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
    }

    //This pinch area is for selection
    PinchArea {
        id: pinchArea
        anchors {
            left: parent.left
            top: parent.top
            right: sidebarPlaceHolder.left
            bottom: parent.bottom
        }
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
                    print(fileBrowserRoot.model)
                    if (selectedModel.count > 0 && Math.abs(mouse.y - startY) > 200) {
                        parent.enabled = true
                    }
                }
                MobileComponents.IconGrid {
                    id: resultsGrid
                    anchors.fill: parent

                    model: fileBrowserRoot.model

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

                            property string label: model.label ? model.label : model.display

                            width: resultsGrid.delegateWidth
                            height: resultsGrid.delegateHeight
                            onPressAndHold: {
                                resourceInstance.uri = model["url"] ? model["url"] : model["resourceUri"]
                                resourceInstance.title = model["label"]
                            }
                            onClicked: openFile(model["url"], mimeType)
                        }
                    }
                }
            }
        }
    }

    Item {
        id: sidebarPlaceHolder
        width: sidebar.open ? parent.width/4 : 0
        anchors {
            right: parent.right
            top: parent.top
            bottom: parent.bottom
        }
    }
    Image {
        id: sidebar
        source: "image://appbackgrounds/contextarea"
        fillMode: Image.Tile
        property bool open: true

        width: parent.width/4
        x: parent.width - width
        Behavior on width {
            NumberAnimation {
                duration: 250
                easing.type: Easing.InOutQuad
            }
        }
        anchors {
            top: parent.top
            bottom: parent.bottom
        }

        PlasmaCore.FrameSvgItem {
            imagePath: "dialogs/background"
            enabledBorders: "LeftBorder|TopBorder|BottomBorder"
            width: handleIcon.width + margins.left + margins.right
            height: handleIcon.height + margins.top + margins.bottom
            anchors {
                right: parent.left
                verticalCenter: sidebar.verticalCenter
                rightMargin: -1
            }

            //TODO: an icon
            Item {
                id: handleIcon
                x: parent.margins.left
                y: parent.margins.top
                width: theme.smallMediumIconSize
                height: width * 1.6
            }
            MouseArea {
                anchors.fill: parent
                drag {
                    target: sidebar
                    axis: Drag.XAxis
                    minimumX: resourceBrowser.width - sidebar.width
                    maximumX: resourceBrowser.width
                }
                onReleased: {
                    sidebar.open = (sidebar.x < resourceBrowser.width - sidebar.width/2)
                    sidebarSlideAnimation.to = sidebar.open ? resourceBrowser.width - sidebar.width : resourceBrowser.width
                    sidebarSlideAnimation.running = true
                }
            }
        }
        NumberAnimation {
            id: sidebarSlideAnimation
            target: sidebar
            properties: "x"
            duration: 250
            easing.type: Easing.InOutQuad
        }
        Image {
            z: 800
            source: "image://appbackgrounds/shadow-right"
            fillMode: Image.TileVertically
            anchors {
                left: parent.left
                top: parent.top
                bottom: parent.bottom
            }
        }

        Item {
            anchors.fill: parent
            clip: true
            PlasmaComponents.PageStack {
                id: sidebarStack
                width: fileBrowserRoot.width/4 - theme.defaultFont.mSize.width * 2
                initialPage: Qt.createComponent("CategorySidebar.qml")
                anchors {
                    left: parent.left
                    top: parent.top
                    bottom: parent.bottom
                    bottomMargin: 0
                    topMargin: toolBar.height
                    leftMargin: theme.defaultFont.mSize.width * 2
                    rightMargin: theme.defaultFont.mSize.width
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
    SlcComponents.SlcMenu {
        id: contextMenu
    }
}

