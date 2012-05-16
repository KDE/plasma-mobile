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
                if (searchQuery.length > 3) {
                    // the "*" are needed for substring match.
                    metadataModel.extraParameters["nfo:fileName"] = "*" + searchBox.searchQuery + "*"
                } else {
                    metadataModel.extraParameters["nfo:fileName"] = ""
                }
            }
            busy: metadataModel.running
        }

        Item {
            width: childrenRect.width
            height: childrenRect.height
            clip: true
            anchors {
                right: emptyTrashButton.left
                bottom: parent.bottom
                bottomMargin: -4
                rightMargin: 4
            }
            PlasmaComponents.ButtonRow {
                z: 900
                y: sidebar.open ? 0 : height
                exclusive: true
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

    Image {
        id: browserFrame
        z: 100
        source: "image://appbackgrounds/standard"
        fillMode: Image.Tile
        anchors {
            top: parent.top
            bottom: parent.bottom
        }
        width: parent.width
        x: 0

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
                        if (selectedModel.count > 0 && Math.abs(mouse.y - startY) > 200 && !contextMenu.visible) {
                            parent.enabled = true
                        }
                    }
                    onReleased: {
                        selectedModel.modelCleared()
                        selectedModel.clear()
                        selectionRect.x = -1
                        selectionRect.y = -1
                        selectionRect.width = 0
                        selectionRect.height = 0
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

                                property bool contains: resourceDelegate.x+resourceDelegate.width > selectionRect.x && resourceDelegate.y+resourceDelegate.height > selectionRect.y && resourceDelegate.x < selectionRect.x+selectionRect.width && resourceDelegate.y < selectionRect.y+selectionRect.height
                                opacity: 0
                                /*Behavior on opacity {
                                    NumberAnimation {duration: 250}
                                }*/
                                onContainsChanged: {
                                    if (contains) {
                                        selectedModel.append({"url": model.url})
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
                                onPressAndHold: {
                                    resourceInstance.uri = model["url"] ? model["url"] : model["resourceUri"]
                                    resourceInstance.title = model["label"]
                                    if (highlightFrame.opacity == 1) {
                                        for (var i = 0; i < selectedModel.count; ++i) {
                                            if ((model.url && model.url == selectedModel.get(i).url)) {
                                                highlightFrame.opacity = 0
                                                selectedModel.remove(i)
                                                return
                                            }
                                        }
                                    } else {
                                        highlightFrame.opacity = 1
                                        selectedModel.append({"url": model.url})
                                    }
                                }
                                onClicked: openFile(model["url"], mimeType)
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
        Image {
            source: "image://appbackgrounds/shadow-right"
            fillMode: Image.TileVertically
            anchors {
                left: parent.right
                top: parent.top
                bottom: parent.bottom
                leftMargin: -1
            }
        }
        PlasmaCore.FrameSvgItem {
            id: handleGraphics
            imagePath: "dialogs/background"
            enabledBorders: "LeftBorder|TopBorder|BottomBorder"
            width: handleIcon.width + margins.left + margins.right + 4
            height: handleIcon.width * 1.6 + margins.top + margins.bottom + 4
            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
            }

            //TODO: an icon
            PlasmaCore.SvgItem {
                id: handleIcon
                svg: PlasmaCore.Svg {imagePath: "toolbar-icons/show"}
                elementId: "show-menu"
                x: parent.margins.left
                y: parent.margins.top
                width: theme.smallMediumIconSize
                height: width
                anchors.verticalCenter: parent.verticalCenter
            }
        }
        MouseArea {
            anchors {
                top: parent.top
                bottom: parent.bottom
                left: handleGraphics.left
                right: handleGraphics.right
            }
            drag {
                target: browserFrame
                axis: Drag.XAxis
                //-50, an overshoot to make it look smooter
                minimumX: -sidebar.width - 50
                maximumX: 0
            }
            property int startX
            property bool toggle: true
            onPressed: {
                startX = browserFrame.x
                toggle = true
            }
            onPositionChanged: {
                if (Math.abs(browserFrame.x - startX) > 20) {
                    toggle = false
                }
            }
            onReleased: {
                if (toggle) {
                    sidebar.open = !sidebar.open
                } else {
                    sidebar.open = (browserFrame.x < -sidebar.width/2)
                }
                sidebarSlideAnimation.to = sidebar.open ? -sidebar.width : 0
                sidebarSlideAnimation.running = true
            }
        }
        //FIXME: use a state machine
        SequentialAnimation {
            id: sidebarSlideAnimation
            property alias to: actualSlideAnimation.to
            NumberAnimation {
                id: actualSlideAnimation
                target: browserFrame
                properties: "x"
                duration: 250
                easing.type: Easing.InOutQuad
            }
            ScriptAction {
                script: pinchArea.anchors.leftMargin = -browserFrame.x
            }
        }
    }

    Item {
        id: sidebar

        property bool open: false

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

    Image {
        source: "image://appbackgrounds/shadow-bottom"
        fillMode: Image.TileHorizontally
        opacity: 0.8
        anchors {
            left: parent.left
            top: toolBar.bottom
            right: parent.right
            topMargin: -2
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

