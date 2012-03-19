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

import QtQuick 1.0
import org.kde.metadatamodels 0.1 as MetadataModels
import org.kde.plasma.components 0.1 as PlasmaComponents
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents
import org.kde.plasma.slccomponents 0.1 as SlcComponents
import org.kde.qtextracomponents 0.1


PlasmaComponents.Page {
    id: viewerPage
    anchors.fill: parent

    state: "toolsClosed"

    signal zoomIn
    signal zoomOut

    tools: Item {
        height: childrenRect.height
        PlasmaComponents.ToolButton {
            id: backIcon
            anchors.left: parent.left
            iconSource: "go-previous"
            width: theme.largeIconSize
            height: width
            flat: false
            onClicked: {
                //we want to tell the current image was closed
                resourceInstance.uri = ""
                mainStack.pop()
            }
        }
        Text {
            text: i18n("%1 of %2", fullList.currentIndex+1, fullList.count)
            anchors.centerIn: parent
            font.pointSize: 14
            font.bold: true
            color: theme.textColor
            style: Text.Raised
            styleColor: theme.backgroundColor
        }
        Row {
            anchors.right: parent.right
            PlasmaComponents.ToolButton {
                iconSource: "zoom-in"
                width: theme.largeIconSize
                height: width
                flat: false
                onClicked: viewerPage.zoomIn()
            }
            PlasmaComponents.ToolButton {
                iconSource: "zoom-out"
                width: theme.largeIconSize
                height: width
                flat: false
                onClicked: viewerPage.zoomOut()
            }
        }
    }

    function loadFile(path)
    {
        if (path.length == 0) {
            return
        }

        if (String(path).indexOf("/") === 0) {
            path = "file://"+path
        }

        //is in Nepomuk
        var index = metadataModel.find(path);
        if (index > -1) {
            fullList.model = metadataModel
            fullList.positionViewAtIndex(index, ListView.Center)
            fullList.currentIndex = index
            //spareDelegate.visible = false
            fullList.visible = true
            fileBrowserRoot.state = "image"
            return
        } else {
            //is in dirModel
            fullList.model = dirModel
            index = dirModel.indexForUrl(path)
            fullList.positionViewAtIndex(index, ListView.Center)
            fullList.currentIndex = index
            //spareDelegate.visible = false
            fullList.visible = true
            fileBrowserRoot.state = "image"
        }
        spareDelegate.source = path
    }

    function setCurrentIndex(index)
    {
        fullList.positionViewAtIndex(index, ListView.Center)
        fullList.currentIndex = index
    }

    Rectangle {
        id: viewer

        color: "black"
        anchors.fill:  parent

        ListView {
            id: fullList
            anchors.fill: parent
            model: metadataModel
            highlightRangeMode: ListView.StrictlyEnforceRange
            orientation: ListView.Horizontal
            snapMode: ListView.SnapOneItem
            cacheBuffer: 40
            //highlightFollowsCurrentItem: true
            delegate: FullScreenDelegate {
                source: model["url"]
            }

            onCurrentIndexChanged: {
                resourceInstance.uri = currentItem.source
                resourceInstance.title = currentItem.label
                quickBrowserBar.setCurrentIndex(currentIndex)
            }
            visible: false
        }
    }

    MouseEventListener {
        width: parent.width
        height: parent.height

        property int lastX
        onPressed: lastX = mouse.screenX
        onPositionChanged: {
            x += (mouse.screenX - lastX)
            lastX = mouse.screenX
        }
        FullScreenDelegate {
            id: spareDelegate
            anchors {
                fill:  parent
            }
            //visible: false
        }
    }

    QuickBrowserBar {
        id: quickBrowserBar
        model: fileBrowserRoot.model
    }

    states: [
        State {
            name: "toolsOpen"
            PropertyChanges {
                target: toolBar
                y: 0
            }
            PropertyChanges {
                target: quickBrowserBar
                y: fileBrowserRoot.height - quickBrowserBar.height
            }
        },
        State {
            name: "toolsClosed"
            PropertyChanges {
                target: toolBar
                y: -toolBar.height
            }
            PropertyChanges {
                target: quickBrowserBar
                y: fileBrowserRoot.height+20
            }
        }
    ]

    transitions: [
        Transition {
            NumberAnimation {
                properties: "y"
                easing.type: Easing.InOutQuad
                duration: 250
            }
        }
    ]
}

