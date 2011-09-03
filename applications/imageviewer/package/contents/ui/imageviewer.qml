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
import org.kde.plasma.slccomponents 0.1 as SlcComponents

Image {
    id: imageViewer
    objectName: "imageViewer"
    source: viewerPackage.filePath("images", "fabrictexture.png")
    fillMode: Image.Tile

    width: 360
    height: 360

    property bool firstRun: true

    MobileComponents.Package {
        id: viewerPackage
        name: "org.kde.active.imageviewer"
    }

    MobileComponents.ResourceInstance {
        id: resourceInstance
    }

    PlasmaCore.Theme {
        id: theme
    }

    function loadImage(path)
    {
        if (path.length == 0) {
            return
        }

        var i = 0
        if (String(path).indexOf("/") === 0) {
            path = "file://"+path
        }

        for (prop in metadataSource.data["ResourcesOfType:Image"]) {
            if (metadataSource.data["ResourcesOfType:Image"][prop]["url"] == path) {
                fullList.positionViewAtIndex(i, ListView.Center)
                fullList.currentIndex = i
                spareDelegate.visible = false
                fullList.visible = true
                viewer.scale = 1
                return
            }
            ++i
        }

        spareDelegate.source = path
        resourceInstance.uri = path
        spareDelegate.visible = true
        fullList.visible = false
        viewer.scale = 1
    }

    Timer {
        id: firstRunTimer
        interval: 300
        repeat: false
        onTriggered: {
            loadImage(startupArguments[0])
            imageViewer.firstRun = false
        }
    }

    PlasmaCore.DataSource {
        id: metadataSource
        engine: "org.kde.active.metadata"
        connectedSources: ["ResourcesOfType:Image"]
        interval: 0
        onDataChanged: {
            firstRunTimer.restart()
        }
    }
    PlasmaCore.SortFilterModel {
        id: filterModel
        sourceModel: PlasmaCore.DataModel {
            id: metadataModel
            keyRoleFilter: ".*"
            dataSource: metadataSource
        }
        filterRole: "label"
    }

    Timer {
       id: queryTimer
       running: true
       repeat: false
       interval: 1000
       onTriggered: {
            filterModel.filterRegExp = ".*"+searchBox.searchQuery+".*"
       }
    }


    PlasmaCore.FrameSvgItem {
        id: toolbar
        anchors {
            left: parent.left
            right: parent.right
        }
        signal zoomIn()
        signal zoomOut()

        height: childrenRect.height + margins.bottom
        imagePath: "widgets/frame"
        prefix: "raised"
        enabledBorders: "BottomBorder"
        z: 9000
        Behavior on y {
            NumberAnimation {
                duration: 250
                easing.type: Easing.InOutQuad
            }
        }

        QIconItem {
            icon: QIcon("go-previous")
            width: 48
            height: 48
            opacity: viewer.scale==1?1:0
            anchors.verticalCenter: parent.verticalCenter
            Behavior on opacity {
                NumberAnimation {
                    duration: 250
                    easing.type: Easing.InOutQuad
                }
            }
            MouseArea {
                anchors.fill: parent
                onClicked: viewer.scale = 0
            }
        }
        Text {
            text: i18n("%1 of %2", fullList.currentIndex+1, fullList.count)
            anchors.centerIn: parent
            font.pointSize: 14
            font.bold: true
            color: theme.textColor
            visible: viewer.scale==1
            style: Text.Raised
            styleColor: theme.backgroundColor
        }
        MobileComponents.ViewSearch {
            id: searchBox
            anchors {
                left: parent.left
                right:parent.right
                top:parent.top
            }
            onSearchQueryChanged: {
                queryTimer.running = true
            }
            opacity: viewer.scale==1?0:1
            Behavior on opacity {
                NumberAnimation {
                    duration: 250
                    easing.type: Easing.InOutQuad
                }
            }
        }

        PlasmaCore.Svg {
            id: iconsSvg
            imagePath: "widgets/configuration-icons"
        }
        Row {
            opacity: viewer.scale==1?1:0
            Behavior on opacity {
                NumberAnimation {
                    duration: 250
                    easing.type: Easing.InOutQuad
                }
            }
            anchors {
                verticalCenter: parent.verticalCenter
                right: parent.right
            }
            //TODO: ad hoc icons
            MobileComponents.ActionButton {
                svg: iconsSvg
                elementId: "add"
                onClicked: {
                    toolbar.zoomIn()
                }
            }
            MobileComponents.ActionButton {
                svg: iconsSvg
                elementId: "remove"
                onClicked: {
                    toolbar.zoomOut()
                }
            }
        }
    }

    Rectangle {
        id: bottomNavigation
        //FIXME: use the state machine
        y: toolbar.y==0&&viewer.scale==1?imageViewer.height-bottomNavigation.height:imageViewer.height+20
        Behavior on y {
            NumberAnimation {
                duration: 250
                easing.type: Easing.InOutQuad
            }
        }
        z: 9999
        color: Qt.rgba(1, 1, 1, 0.7)

        anchors {
            left: parent.left
            right: parent.right
        }

        height: 65
        PlasmaCore.DataSource {
            id: previewSource
            engine: "preview"
        }
        ListView {
            id: bottomThumbnails
            spacing: 1
            anchors {
                fill: parent
                topMargin: 1
            }
            orientation: ListView.Horizontal
            model: filterModel

            delegate: QImageItem {
                id: delegate
                z: index==bottomThumbnails.currentIndex?200:0
                scale: index==bottomThumbnails.currentIndex?1.4:1
                Behavior on scale {
                    NumberAnimation {
                        duration: 250
                        easing.type: Easing.InOutQuad
                    }
                }
                width: height*1.6
                height: bottomThumbnails.height
                image: previewSource.data[url]["thumbnail"]
                Component.onCompleted: {
                    previewSource.connectSource(url)
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        bottomThumbnails.currentIndex = index
                        fullList.positionViewAtIndex(index, ListView.Center)
                        fullList.currentIndex = index
                    }
                }
            }
        }
    }

    MobileComponents.IconGrid {
        id: resultsGrid
        anchors {
            fill: parent
            topMargin: toolbar.height
        }

        Component.onCompleted: resultsContainer.contentY = resultsContainer.height
        height: resultsContainer.height
        model: filterModel
        delegateWidth: 130
        delegateHeight: 120
        delegate: MobileComponents.ResourceDelegate {
            id: resourceDelegate
            width: 130
            height: 120
            infoLabelVisible: false

            onPressed: {
                resourceInstance.uri = model["url"]?model["url"]:model["resourceUri"]
                resourceInstance.title = model["label"]
            }

            onClicked: {
                loadImage(model["url"])
            }
        }
    }

    Rectangle {
        id: viewer
        scale: startupArguments[0].length > 0?1:0
        //FIXME: use states
        onScaleChanged: {
            if (scale == 1) {
                toolbar.y = -toolbar.height
            }
        }
        color: "#ddd"
        anchors {
            fill:  parent
        }
        Behavior on scale {
            NumberAnimation {
                duration: 250
                easing.type: Easing.InOutQuad
            }
        }
        FullScreenDelegate {
            id: spareDelegate
            anchors {
                fill:  parent
            }
            visible: false
        }
        ListView {
            id: fullList
            anchors.fill: parent
            model: filterModel
            highlightRangeMode: ListView.StrictlyEnforceRange
            orientation: ListView.Horizontal
            snapMode: ListView.SnapOneItem
            //highlightFollowsCurrentItem: true
            delegate: FullScreenDelegate {
                source: model["url"]
            }

            onCurrentIndexChanged: {
                resourceInstance.uri = currentItem.source
                resourceInstance.title = currentItem.label
                bottomThumbnails.positionViewAtIndex(currentIndex, ListView.Center)
                bottomThumbnails.currentIndex = currentIndex
            }
            visible: false
        }

    }
}
