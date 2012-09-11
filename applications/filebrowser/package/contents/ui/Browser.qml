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


MobileComponents.SplitDrawer {
    id: resourceBrowser
    objectName: "resourceBrowser"
    property string currentUdi
    anchors {
        fill: parent
        topMargin: toolBar.height
    }

    tools: Item {
        width: parent.width
        height: childrenRect.height

        PlasmaCore.DataModel {
            id: devicesModel
            dataSource: hotplugSource
        }

        Row {
            id: devicesFlow
            spacing: 4
            anchors {
               // bottom: parent.bottom
               verticalCenter: parent.verticalCenter
               left: parent.left
            }

            property int itemCount: 1
            property string currentUdi

            Item {
                width: theme.largeIconSize
                height: width
                PlasmaComponents.ToolButton {
                    id: upButton
                    anchors.fill: parent
                    flat: false
                    iconSource: "go-up"
                    visible: currentUdi != "" &&
                        devicesSource.data[currentUdi] &&
                        dirModel.url.indexOf(devicesSource.data[currentUdi]["File Path"]) !== -1 &&
                        "file://" + devicesSource.data[currentUdi]["File Path"] !== dirModel.url
                    onClicked: dirModel.url = dirModel.url+"/.."
                }
            }

            PlasmaComponents.ToolButton {
                id: localButton
                width: theme.mediumIconSize + 10
                height: width
                iconSource: "drive-harddisk"
                checked: fileBrowserRoot.model == metadataModel
                onClicked: checked = true
                onCheckedChanged: {
                    if (checked) {
                        for (var i = 0; i < devicesFlow.children.length; ++i) {
                            var child = devicesFlow.children[i]
                            if (child != localButton && child.checked !== undefined) {
                                child.checked = false
                            }
                        }
                        for (child in devicesFlow.children) {
                            if (child != localButton) {
                                child.checked = false
                            }
                        }
                        fileBrowserRoot.model = metadataModel
                        //nepomuk db, not filesystem
                        resourceBrowser.currentUdi = ""
                    }
                }
                DropArea {
                    enabled: !parent.checked
                    anchors.fill: parent
                    onDragEnter: parent.flat = false
                    onDragLeave: parent.flat = true
                    onDrop: {
                        parent.flat = true
                        application.copy(event.mimeData.urls, "~")
                    }
                }
            }


            Repeater {
                id: devicesRepeater
                model: devicesModel

                delegate: PlasmaComponents.ToolButton {
                    id: removableButton
                    width: theme.mediumIconSize + 10
                    height: width
                    visible: devicesSource.data[udi]["Removable"] == true
                    iconSource: model["icon"]
                    onClicked: checked = true
                    onCheckedChanged: {
                        if (checked) {
                            for (var i = 0; i < devicesFlow.children.length; ++i) {
                                var child = devicesFlow.children[i]
                                if (child != removableButton && child.checked !== undefined) {
                                    child.checked = false
                                }
                            }
                            resourceBrowser.currentUdi = udi

                            if (devicesSource.data[udi]["Accessible"]) {
                                dirModel.url = devicesSource.data[udi]["File Path"]

                                fileBrowserRoot.model = dirModel
                            } else {
                                var service = devicesSource.serviceForSource(udi);
                                var operation = service.operationDescription("mount");
                                service.startOperationCall(operation);
                            }
                        }
                    }
                    DropArea {
                        enabled: !parent.checked
                        anchors.fill: parent
                        onDragEnter: parent.flat = false
                        onDragLeave: parent.flat = true
                        onDrop: {
                            application.copy(event.mimeData.urls, devicesSource.data[udi]["File Path"])
                            parent.flat = true
                        }
                    }
                }
            }

            PlasmaComponents.ToolButton {
                id: trashButton
                width: theme.mediumIconSize + 10
                height: width
                parent: devicesFlow
                iconSource: "user-trash"
                onClicked: checked = true
                onCheckedChanged: {
                    if (checked) {
                        for (var i = 0; i < devicesFlow.children.length; ++i) {
                            var child = devicesFlow.children[i]
                            if (child != trashButton && child.checked !== undefined) {
                                child.checked = false
                            }
                        }
                        resourceBrowser.currentUdi = ""

                        dirModel.url = "trash:/"

                        fileBrowserRoot.model = dirModel
                    }
                }
                DropArea {
                    enabled: !parent.checked
                    anchors.fill: parent
                    onDragEnter: parent.flat = false
                    onDragLeave: parent.flat = true
                    onDrop: {
                        parent.flat = true
                        application.trash(event.mimeData.urls)
                    }
                }
            }
        }

        MobileComponents.ViewSearch {
            id: searchBox
            anchors.centerIn: parent
            visible: fileBrowserRoot.model == metadataModel

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
                y: resourceBrowser.open ? 0 : height
                exclusive: true
                Behavior on y {
                    NumberAnimation {
                        duration: 250
                        easing.type: Easing.InOutQuad
                    }
                }
                SidebarTab {
                    id: mainTab
                    text: i18n("Filters")
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

    Item {
        id: browserFrame
        anchors.fill: parent

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
                if (resultsGrid.model == dirModel) {
                    var udi
                    var path

                    for (var i in devicesSource.connectedSources) {
                        udi = devicesSource.connectedSources[i]
                        path = devicesSource.data[udi]["File Path"]
                        print(udi+dirModel.url.indexOf(udi))
                        if (dirModel.url.indexOf(path) > 2) {
                            resourceBrowser.currentUdi = udi
                            break
                        }
                    }
                } else if (resultsGrid.model != dirModel && devicesSource.data[resourceBrowser.currentUdi]["File Path"] != "") {
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
                        if (selectedModel.count > 0 && Math.abs(mouse.y - startY) > 200) {
                            dragArea.enabled = true
                        }
                    }

                    onReleased: {
                        //are we outside the listview area?
                        if (resultsGrid.childAt(mouse.x, mouse.y).delegate === undefined && selectionRect.width == 0) {
                            selectedModel.clear()
                            selectedModel.modelCleared()
                        }
                    }
                    Connections {
                        target: fileBrowserRoot.model
                        onCountChanged: pinchArea.resetSelection()
                        onModelReset: pinchArea.resetSelection()
                    }
                    MobileComponents.IconGrid {
                        id: resultsGrid
                        anchors.fill: parent

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

                                property bool contains: resourceDelegate.x+resourceDelegate.width > selectionRect.x && resourceDelegate.y+resourceDelegate.height > selectionRect.y && resourceDelegate.x < selectionRect.x+selectionRect.width && resourceDelegate.y < selectionRect.y+selectionRect.height
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
                                        selectedModel.append(model)
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
    }

    drawer: Item {
        id: sidebar

        anchors.fill: parent

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
}

