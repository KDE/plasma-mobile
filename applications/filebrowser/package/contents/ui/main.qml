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
import org.kde.dirmodel 0.1
import org.kde.metadatamodels 0.1 as MetadataModels
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.components 0.1 as PlasmaComponents
import org.kde.plasma.extras 0.1 as PlasmaExtras
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents


Image {
    id: fileBrowserRoot

    //BEGIN properties
    width: 360
    height: 360
    
    property QtObject model: metadataModel
    
    objectName: "fileBrowserRoot"
    source: "image://appbackgrounds/contextarea"
    fillMode: Image.Tile
    state: "browsing"
    //END properties

    //BEGIN model
    MetadataModels.MetadataModel {
        id: metadataModel
        sortBy: [userTypes.sortFields[metadataModel.resourceType]]
        //sortOrder: Qt.DescendingOrder
        //queryString: "pdf"
        resourceType: exclusiveResourceType
        mimeTypes: exclusiveMimeTypes
    }

    PlasmaCore.DataSource {
        id: activitySource
        engine: "org.kde.activities"
        connectedSources: ["Status"]
    }

    DirModel {
        id: dirModel
    }
    //END model

    //BEGIN functions    
    function goBack() {
        toolBar.y = 0;

        //don't go more back than the browser
        if (mainStack.currentPage.objectName == "resourceBrowser") {
            return;
        }

        if (mainStack.depth == 1) {
            if (exclusiveResourceType || exclusiveMimeTypes.length > 0) {
                mainStack.replace(Qt.createComponent("Browser.qml"));
            } else {
                mainStack.replace(Qt.createComponent("Intro.qml"));
            }
        } else {
            mainStack.pop();
        }
    }

    function openFile(url, mimeType) {
        if (mimeType == "inode/directory") {
            dirModel.url = url
            fileBrowserRoot.model = dirModel
        } else if (!mainStack.busy) {
            var packageName = application.packageForMimeType(mimeType)
            print("Package for mimetype " + mimeType + " " + packageName)
            if (packageName) {
                partPackage.name = packageName
                if (partPackage.visibleName && partPackage.visibleName != '') {
                    application.caption = partPackage.visibleName
                } else {
                    application.caption = i18n('Files')
                }
                var part = mainStack.push(partPackage.filePath("mainscript"))
                part.loadFile(url)
            } else {
                Qt.openUrlExternally(url)
            }
        }
    }
    //END functions

    //BEGIN non-UI components
    PlasmaExtras.ResourceInstance {
        id: resourceInstance
    }

    MobileComponents.Package {
        id: partPackage
    }

    MetadataModels.MetadataUserTypes {
        id: userTypes
    }

    Timer {
        interval: 500
        running: true
        onTriggered: {
            if (mainStack.depth > 0) {
                return
            }
            if (exclusiveResourceType || exclusiveMimeTypes.length > 0) {
                mainStack.push(Qt.createComponent("Browser.qml"))
            } else {
                mainStack.push(Qt.createComponent("Intro.qml"))
            }
        }
    }
    
    //FIXME: this is due to global vars being binded after the parse is done, do the 2 steps parsing
    Timer {
        interval: 100
        running: true
        onTriggered: {
            if (application.startupArguments.length > 0) {
                var path = application.startupArguments[0]

                if (startupMimeType == "inode/directory") {
                    if (mainStack.depth == 0) {
                        mainStack.push(Qt.createComponent("Browser.qml"))
                    }
                }
                openFile(path, startupMimeType)
            }
        }
    }
    //END non-UI components
    
    //BEGIN: UI components
    PlasmaComponents.BusyIndicator {
        anchors.centerIn: mainStack
        visible: metadataModel.running
        running: visible
    }

    PlasmaComponents.ToolBar {
        id: toolBar
        height: tools ? theme.hugeIconSize : 0
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
    //END UI components
}
