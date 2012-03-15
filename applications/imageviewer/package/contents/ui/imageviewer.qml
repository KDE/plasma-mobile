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
import org.kde.plasma.extra 0.1 as PlasmaExtra
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents
import org.kde.plasma.slccomponents 0.1 as SlcComponents
import org.kde.qtextracomponents 0.1


Image {
    id: imageViewer
    objectName: "imageViewer"
    source: "image://appbackgrounds/standard"
    fillMode: Image.Tile
    state: "browsing"

    width: 360
    height: 360


    signal zoomIn
    signal zoomOut


    MobileComponents.Package {
        id: viewerPackage
        name: "org.kde.active.imageviewer"
    }

    PlasmaExtra.ResourceInstance {
        id: resourceInstance
    }

    function loadImage(path)
    {
        if (path.length == 0) {
            return
        }

        var viewerItem = mainStack.push(Qt.createComponent("ViewerPage.qml"))
        viewerItem.loadImage(path)
    }

    Timer {
        id: firstRunTimer
        interval: 300
        repeat: false
        onTriggered: {
            loadImage(application.startupArguments[0])

            // sort by column 0 (called "label" in metadatamodel.cpp),
            // that is, the file name.
            metadataModel.sort(0)
        }
    }

    MetadataModels.MetadataUserTypes {
        id: userTypes
    }
    MetadataModels.MetadataModel {
        id: metadataModel
        resourceType: "nfo:Image"
        sortBy: [userTypes.sortFields[resourceType]]
        sortOrder: Qt.AscendingOrder
        property bool starting: true
        onStatusChanged: {
            if (status == MetadataModels.MetadataModel.Idle && starting) {
                firstRunTimer.running = true
                starting = false
            }
        }
    }


    PlasmaComponents.ToolBar {
        id: toolBar
    }

    PlasmaComponents.PageStack {
        id: mainStack
        clip: false
        toolBar: toolBar
        initialPage: Qt.createComponent("Browser.qml")
        anchors.fill: parent
    }

 
    SlcComponents.SlcMenu {
        id: contextMenu
    }
}
