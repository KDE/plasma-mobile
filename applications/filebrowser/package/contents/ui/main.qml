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

    MobileComponents.Package {
        id: homeScreenPackage
        name: "org.kde.active.contour-tablet-homescreen"
    }


    MetadataModels.MetadataUserTypes {
        id: userTypes
    }
    MetadataModels.MetadataModel {
        id: metadataModel
        sortBy: [userTypes.sortFields[metadataModel.resourceType]]
        //sortOrder: Qt.DescendingOrder
        //queryString: "pdf"
    }
    DirModel {
        id: dirModel
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

    Item {
        anchors {
            right: sideBar.left
            top: parent.top
            bottom: parent.bottom
            left: parent.left
        }
        onWidthChanged: mainStackSyncTimer.restart()
        Timer {
            id: mainStackSyncTimer
            interval: 200
            onTriggered: mainStack.width = parent.width
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
    }

    Timer {
        interval: 1000
        running: true
        onTriggered: {
            mainStack.push(Qt.createComponent("Browser.qml"))
            sidebarStack.push(Qt.createComponent("CategorySidebar.qml"))

            emptyTab.checked = (exclusiveResourceType !== "")

            if (application.startupArguments.length > 0) {
                openFile(application.startupArguments[0])
            }
        }
    }
    /*Timer {
        interval: 5000
        running: true
        onTriggered: {
            if (application.startupArguments.length > 0) {
                openFile(application.startupArguments[0])
            }
        }
    }*/

    PlasmaComponents.ButtonColumn {
        z: 900
        anchors {
            right: sideBar.left
            verticalCenter: sideBar.verticalCenter
            rightMargin: -1
        }
        SidebarTab {
            text: i18n("Main")
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
        function uncheckAll()
        {
            emptyTab.checked = true
        }
        //FIXME: hack to make no item selected
        Item {
            id: emptyTab
            property bool checked: false
            onCheckedChanged: {
                if (checked) {
                    while (sidebarStack.depth > 1) {
                        sidebarStack.pop()
                    }
                }
            }
        }
    }
    Image {
        id: sideBar
        source: "image://appbackgrounds/contextarea"
        fillMode: Image.Tile
        clip: true

        width: emptyTab.checked ? 0 : parent.width/4
        Behavior on width {
            NumberAnimation {
                duration: 250
                easing.type: Easing.InOutQuad
            }
        }
        anchors {
            right: parent.right
            top: parent.top
            bottom: parent.bottom
        }
        Image {
            z: 800
            source: "image://appbackgrounds/shadow-right"
            fillMode: Image.TileVertically
            anchors {
                left: parent.left
                top: parent.top
                bottom: parent.bottom
            }
        }

        PlasmaComponents.PageStack {
            id: sidebarStack
            width: fileBrowserRoot.width/4 - theme.defaultFont.mSize.width * 2
            //initialPage: Qt.createComponent("CategorySidebar.qml")
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

    SlcComponents.SlcMenu {
        id: contextMenu
    }
}
