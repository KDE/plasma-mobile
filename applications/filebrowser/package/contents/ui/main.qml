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

import QtQuick 2.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.mobilecomponents 0.2 as MobileComponents
import org.kde.baloo 0.1 as Baloo
import org.kde.activities 0.1 as Activities
import org.kde.draganddrop 2.0
import org.kde.plasma.private.folder 0.1 as Folder
import org.kde.kio 1.0 as Kio

Rectangle {
    id: fileBrowserRoot

    //BEGIN properties
    width: 360
    height: 360

    property QtObject model: balooDataModel

    objectName: "fileBrowserRoot"
    color: theme.backgroundColor
    Rectangle {
        anchors.fill: parent
        color: theme.highlightColor
        opacity: 0.05
    }
    state: "browsing"
    //END properties

    //BEGIN model
    PlasmaCore.SortFilterModel {
        id: balooDataModel
        sourceModel: Baloo.BalooDataModel {}
    }

    PlasmaCore.SortFilterModel {
        id: activitySource
        sourceModel: Activities.ResourceModel {
            shownAgents: ":any"
            shownActivities: ":current"
        }
    }

    Kio.KRun {
        id: krun
    }

    PlasmaCore.SortFilterModel {
        id: folderModel
        sourceModel: Folder.FolderModel {
            previews: false
        }
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
            for (var i in devicesSource.connectedSources) {
                var udi = devicesSource.connectedSources[i]
                var path = devicesSource.data[udi]["File Path"]
                folderModel.sourceModel.url =path
            }
        }
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
            mainStack.replace(Qt.createComponent("Browser.qml"))
        } else {
            mainStack.pop();
        }
    }

    Image {
        anchors {
            centerIn: parent
            verticalCenterOffset: Math.round(toolBar.height/2)
            horizontalCenterOffset: - Math.round(parent.width / 8)
        }
        x: y
        source: Qt.resolvedUrl("../images/background-logo.png")
    }

    PlasmaComponents.ToolBar {
        id: toolBar
        height: tools && tools.item !== null ? units.iconSizes.huge : 0
    }

    function openResource(data)
    {
        if(data.isDir) {
            folderModel.sourceModel.url = data.url
        } else if (!mainStack.busy) {
            //TODO Port it together with the imageviewer
            /*var packageName = application.viewerPackageForType(data.mimeType)
            print("Package for mimetype " + data.mimeType + " " + packageName)
            if (packageName) {
                partPackage.name = packageName
                if (partPackage.visibleName && partPackage.visibleName != '') {
                    application.caption = partPackage.visibleName
                } else {
                    application.caption = i18n('Files')
                }
                var part = mainStack.push(partPackage.filePath("mainscript"))
                part.loadResource(data)
            } */
            krun.openUrl(data.url)
        }
    }
    //END functions

    //BEGIN non-UI components

    Timer {
        interval: 500
        running: true
        onTriggered: {
            if (mainStack.depth > 0) {
                return
            }
            mainStack.push(Qt.createComponent("Browser.qml"))
        }
    }

    //FIXME: this is due to global vars being binded after the parse is done, do the 2 steps parsing
    Timer {
        interval: 100
        running: true
        onTriggered: {
            /*if (application.startupArguments.length > 0) {
                var path = application.startupArguments[0]

                if (startupMimeType == "inode/directory") {
                    if (mainStack.depth == 0) {
                        mainStack.push(Qt.createComponent("Browser.qml"))
                    }
                }
                openResource({"url": path, "mimeType": startupMimeType})
            }*/
        }
    }
    //END non-UI components


    //BEGIN: UI components

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

    //PlasmaComponents.BusyIndicator {
   //     anchors.centerIn: mainStack
        //visible: balooDataModel.running
        //running: visible
    //}

    //END UI components
}
