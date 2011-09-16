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
import QtWebKit 1.0
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents

Image {
    id: aboutApp
    objectName: "aboutApp"
    width: 800
    height: 600
    source: aboutPackage.filePath("images", "background.png")
    fillMode: Image.Tile

    Item { id: headerSpace; width: parent.width; height: header.height }

    property FlickableWebView webView

    MobileComponents.Package {
        id: aboutPackage
        name: "org.kde.active.aboutapp"
    }

    Header {
        id: header
        z: 999
        width: headerSpace.width
        //height: headerSpace.height
    }

    VisualItemModel {
        id: itemModel

        FlickableWebView {
            id: webView
            objectName: "webView"
            url: aboutPackage.filePath("images", "about.html")
            
            width: aboutApp.width
            height: aboutApp.height
        }
        
        FlickableWebView {
            id: webView2
            objectName: "webView2"
            url: aboutPackage.filePath("images", "authors.html")

            width: aboutApp.width
            height: aboutApp.height
        }

        FlickableWebView {
            id: webView3
            objectName: "webView3"
            url: aboutPackage.filePath("images", "license.html")

            width: aboutApp.width
            height: aboutApp.height
        }
    }

    ListView {
        id: view
        anchors {
            top: header.bottom
            bottom: parent.bottom
            left:parent.left
            right: parent.right
            topMargin: -8
        }

        model: itemModel
        preferredHighlightBegin: 0
        preferredHighlightEnd: 0
        interactive: false
        highlightRangeMode: ListView.StrictlyEnforceRange
        orientation: ListView.Horizontal
        snapMode: ListView.SnapOneItem; flickDeceleration: 2000
        cacheBuffer: 200
        onCurrentIndexChanged: aboutApp.webView = currentItem
    }

    
    ScrollBar {
        scrollArea: webView1; width: 8
        anchors { right: parent.right; top: header.bottom; bottom: parent.bottom }
    }

    ScrollBar {
        scrollArea: webView1; height: 8; orientation: Qt.Horizontal
        anchors { right: parent.right; rightMargin: 8; left: parent.left; bottom: parent.bottom }
    }
    ScrollBar {
        scrollArea: webView2; width: 8
        anchors { right: parent.right; top: header.bottom; bottom: parent.bottom }
    }

    ScrollBar {
        scrollArea: webView2; height: 8; orientation: Qt.Horizontal
        anchors { right: parent.right; rightMargin: 8; left: parent.left; bottom: parent.bottom }
    }
    ScrollBar {
        scrollArea: webView3; width: 8
        anchors { right: parent.right; top: header.bottom; bottom: parent.bottom }
    }

    ScrollBar {
        scrollArea: webView3; height: 8; orientation: Qt.Horizontal
        anchors { right: parent.right; rightMargin: 8; left: parent.left; bottom: parent.bottom }
    }
}
