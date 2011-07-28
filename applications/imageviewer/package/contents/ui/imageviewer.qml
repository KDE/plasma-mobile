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

Rectangle {
    id: imageViewer
    objectName: "imageViewer"
    color: "#ddd"

    width: 360
    height: 360

    property bool firstRun: true

    MobileComponents.ResourceInstance {
        id: resourceInstance
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
    PlasmaCore.DataModel {
        id: metadataModel
        keyRoleFilter: ".*"
        dataSource: metadataSource
    }

    MobileComponents.IconGrid {
        id: resultsGrid
        anchors {
            fill: parent
        }

        Component.onCompleted: resultsContainer.contentY = resultsContainer.height
        height: resultsContainer.height
        model: metadataModel
        delegate: MobileComponents.ResourceDelegate {
            id: resourceDelegate
            width: 130
            height: 120
            infoLabelVisible: false

            onClicked: {
                loadImage(model["url"])
            }
        }
    }

    Rectangle {
        id: viewer
        scale: startupArguments[0].length > 0?1:0
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
            model: metadataModel
            highlightRangeMode: ListView.StrictlyEnforceRange
            orientation: ListView.Horizontal
            snapMode: ListView.SnapOneItem
            //highlightFollowsCurrentItem: true
            delegate: FullScreenDelegate {
                source: model["url"]
            }

            onCurrentIndexChanged: resourceInstance.uri = currentItem.source
            visible: false
        }
    }


    QIconItem {
        icon: QIcon("go-previous")
        width: 48
        height: 48
        opacity: viewer.scale==1?1:0
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
}
