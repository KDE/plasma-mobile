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
import QtWebKit 1.0
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.components 0.1 as PlasmaComponents
import org.kde.plasma.extras 0.1 as PlasmaExtras
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents

Image {
    id: aboutApp
    objectName: "aboutApp"
    width: 800
    height: 600
    source: "image://appbackgrounds/standard"
    fillMode: Image.Tile
    property QtObject runtimeInfo

    Item { id: toolBarSpace; width: parent.width; height: toolBar.height }

    property FlickableWebView webView

    MobileComponents.Package {
        id: aboutPackage
        name: "org.kde.active.aboutapp"
    }

    PlasmaComponents.ToolBar {
        id: toolBar
        tools: Item {
            width: parent.width
            height: childrenRect.height
            PlasmaComponents.TabBar {
                anchors.horizontalCenter: parent.horizontalCenter
                PlasmaComponents.TabButton { tab: webView1; text: i18n("About")}
                PlasmaComponents.TabButton { tab: webView2; text: i18n("Authors")}
                PlasmaComponents.TabButton { tab: webView3; text: i18n("License")}
            }
        }
    }

    PlasmaComponents.TabGroup {
        id: view
        anchors {
            top: toolBar.bottom
            bottom: parent.bottom
            left:parent.left
            right: parent.right
            topMargin: -8
        }

        FlickableWebView {
            id: webView1
            objectName: "webView"
            url: aboutPackage.filePath("data", "about.html")

            width: aboutApp.width
            height: aboutApp.height
        }

        FlickableWebView {
            id: webView2
            objectName: "webView2"
            url: aboutPackage.filePath("data", "authors.html")

            width: aboutApp.width
            height: aboutApp.height
        }

        FlickableWebView {
            id: webView3
            objectName: "webView3"
            url: aboutPackage.filePath("data", "license.html")

            width: aboutApp.width
            height: aboutApp.height
        }
    }

}
