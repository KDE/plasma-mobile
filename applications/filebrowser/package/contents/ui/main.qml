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
        name: "org.kde.active.filebrowser"
    }

    MobileComponents.ResourceInstance {
        id: resourceInstance
    }



    MetadataModels.MetadataUserTypes {
        id: userTypes
    }
    MetadataModels.MetadataModel {
        id: metadataModel
        //sortBy: ["nie:title"]
        //sortOrder: Qt.DescendingOrder
        //queryString: "pdf"
        //limit: 20
    }

    PlasmaComponents.BusyIndicator {
        anchors.centerIn: mainStack
        visible: metadataModel.status == MetadataModels.MetadataModel.Running
        running: visible
    }

    PlasmaComponents.ToolBar {
        id: toolBar
    }

    PlasmaComponents.PageStack {
        id: mainStack
        clip: false
        toolBar: toolBar
        initialPage: Qt.createComponent("Browser.qml")
        anchors {
            right: sideBar.left
            top: parent.top
            bottom: parent.bottom
            left: parent.left
        }
    }

    Image {
        id: sideBar
        source: "image://appbackgrounds/contextarea"
        fillMode: Image.Tile
        clip: true

        width: parent.width/4
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
            initialPage: Qt.createComponent("CategorySidebar.qml")
            toolBar: sidebarToolbar
            anchors {
                fill: parent
                bottomMargin: Math.max(10, sidebarToolbar.height)
                topMargin: toolBar.height
                leftMargin: theme.defaultFont.mSize.width * 2
                margins: theme.defaultFont.mSize.width
            }
        }
        PlasmaComponents.ToolBar {
            id: sidebarToolbar
            z: 0
            anchors {
                top: undefined
                bottom: parent.bottom
            }
        }
    }
 
    SlcComponents.SlcMenu {
        id: contextMenu
    }
}
