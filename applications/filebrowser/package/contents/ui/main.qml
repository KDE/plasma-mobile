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
import org.kde.dirmodel 0.1


Image {
    id: fileBrowserRoot
    objectName: "fileBrowserRoot"
    source: "image://appbackgrounds/standard"
    fillMode: Image.Tile
    state: "browsing"
    property QtObject model: metadataModel

    width: 360
    height: 360

    MobileComponents.Package {
        id: partPackage
    }

    MobileComponents.ResourceInstance {
        id: resourceInstance
    }

    MetadataModels.MetadataUserTypes {
        id: userTypes
    }
    MetadataModels.MetadataModel {
        id: metadataModel
        sortBy: [userTypes.sortFields[metadataModel.resourceType]]
        //sortOrder: Qt.DescendingOrder
        //queryString: "pdf"
        resourceType: exclusiveResourceType
    }
    DirModel {
        id: dirModel
    }
    function goBack()
    {
        if (mainStack.depth == 1) {
            mainStack.replace(Qt.createComponent("Browser.qml"))
        } else {
            mainStack.pop()
        }
    }

    PlasmaComponents.BusyIndicator {
        anchors.centerIn: mainStack
        visible: metadataModel.status == MetadataModels.MetadataModel.Running
        running: visible
    }

    PlasmaComponents.ToolBar {
        id: toolBar
    }

    function openFile(url, mimeType)
    {
        if (mimeType == "inode/directory") {
            dirModel.url = url
            model = dirModel
        } else if (!mainStack.busy) {
            var packageName = application.packageForMimeType(mimeType)
            print("Package for mimetype " + mimeType + " " + packageName)
            if (packageName) {
                partPackage.name = packageName
                var part = mainStack.push(partPackage.filePath("mainscript"))
                part.loadFile(url)
            } else {
                Qt.openUrlExternally(url)
            }
        }
    }

    PlasmaComponents.PageStack {
        id: mainStack
        clip: false
        toolBar: toolBar
        //initialPage: Qt.createComponent("Browser.qml")
        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
        }
    }

    Timer {
        interval: 1000
        running: true
        onTriggered: {
            if (mainStack.depth > 0) {
                return
            }
            mainStack.push(Qt.createComponent("Browser.qml"))

            if (application.startupArguments.length > 0) {
                openFile(application.startupArguments[0])
            }
        }
    }
    Timer {
        interval: 100
        running: true
        onTriggered: {
            if (application.startupArguments.length > 0) {
                openFile(application.startupArguments[0])
            }
        }
    }
}
