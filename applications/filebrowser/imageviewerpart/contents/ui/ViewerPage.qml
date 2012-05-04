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
    property string path

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
                fileBrowserRoot.goBack()
            }
        }
        Text {
            text: i18n("%1 (%2 of %3)", quickBrowserBar.currentItem.name, quickBrowserBar.currentIndex+1, quickBrowserBar.count)
            anchors.centerIn: parent
            font.pointSize: 14
            font.bold: true
            color: theme.textColor
            style: Text.Raised
            styleColor: theme.backgroundColor
        }
        Row {
            visible: !deviceCapabilitiesSource.data["Input"]["hasMultiTouch"]
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

        viewerPage.path = path
        //is in Nepomuk
        var index = metadataModel.find(path);
        if (index > -1) {
            fileBrowserRoot.model = metadataModel
            quickBrowserBar.currentIndex = index
            return
        } else {
            index = dirModel.indexForUrl(path)
            if (index > -1) {
                //is in dirModel
                fileBrowserRoot.model = dirModel
                quickBrowserBar.currentIndex = index
            //don't know where it is, just load
            } else {
                imageArea.delegate.source = path
            }
        }
    }

    PlasmaCore.DataSource {
        id: deviceCapabilitiesSource
        engine: "org.kde.devicecapabilities"
        interval: 0
        connectedSources: ["Input"]
    }

    //FIXME: HACK
    Connections {
        target: metadataModel
        onRunningChanged: {
            if (!running) {
                viewerPage.loadFile(viewerPage.path)
            }
        }
    }

    Rectangle {
        id: viewer

        color: "black"
        anchors.fill:  parent
    }

    MouseEventListener {
        id: imageArea
        anchors.fill: parent
        //enabled: !delegate.interactive
        property Item delegate: delegate1
        property Item oldDelegate: delegate2
        property bool incrementing: delegate.delta > 0
        Connections {
            target: imageArea.delegate
            onDeltaChanged: {
                imageArea.oldDelegate.delta = imageArea.delegate.delta
                if (imageArea.delegate.delta > 0) {
                    imageArea.oldDelegate.source = fileBrowserRoot.model.get(quickBrowserBar.currentIndex + 1).url
                } else if (imageArea.delegate.delta < 0) {
                    imageArea.oldDelegate.source =  fileBrowserRoot.model.get(quickBrowserBar.currentIndex - 1).url
                }
            }
        }

        property int startX
        property int starty
        onPressed: {
            startX = mouse.screenX
            startY = mouse.screenY
        }
        onReleased: {
            if (Math.abs(mouse.screenX - startX) < 20 &&
                Math.abs(mouse.screenY - startY) < 20) {
                if (viewerPage.state == "toolsOpen") {
                    viewerPage.state = "toolsClosed"
                } else {
                    viewerPage.state = "toolsOpen"
                }
            } else if (delegate.delta != 0 && delegate.doSwitch) {
                oldDelegate = delegate
                delegate = (delegate == delegate1) ? delegate2 : delegate1
                switchAnimation.running = true
            }
        }
        FullScreenDelegate {
            id: delegate2
            width: parent.width
            height: parent.height
        }
        FullScreenDelegate {
            id: delegate1
            width: parent.width
            height: parent.height
        }
        SequentialAnimation {
            id: switchAnimation
            NumberAnimation {
                target: imageArea.oldDelegate
                properties: "x"
                to: imageArea.incrementing ? -imageArea.oldDelegate.width : imageArea.oldDelegate.width
                easing.type: Easing.InQuad
                duration: 250
            }
            ScriptAction {
                script: {
                    if (imageArea.incrementing) {
                        quickBrowserBar.currentIndex += 1
                    } else {
                        quickBrowserBar.currentIndex -= 1
                    }
                    imageArea.oldDelegate.z = 0
                    imageArea.delegate.z = 10
                    imageArea.oldDelegate.x = 0
                    imageArea.delegate.x = 0
                }
            }
            ScriptAction {
                script: delegate1.delta = delegate2.delta = 0
            }
        }
    }

    QuickBrowserBar {
        id: quickBrowserBar
        model: fileBrowserRoot.model
        onCurrentIndexChanged: {
            var path = fileBrowserRoot.model.get(currentIndex).url
            imageArea.delegate.source = path
            viewerPage.path = path
            resourceInstance.uri = path
        }
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

