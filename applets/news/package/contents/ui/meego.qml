/*
 *   Copyright 2010 Marco Martin <notmart@gmail.com>
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

import Qt 4.7
import com.meego 1.0
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.graphicswidgets 0.1 as PlasmaWidgets

Window {
    id: window

    property string currentTtile;
    property string currentBody;
    property string currentUrl;

    ListModel {
       id: rssList

       ListElement {
           name: "Planet KDE"
           url: "http://planetkde.org/rss20.xml"
       }
       ListElement {
           name: "dot.kde.org: KDE news"
           url: "http://dot.kde.org/rss.xml"
       }
       ListElement {
           name: "Slashdot"
           url: "http://rss.slashdot.org/Slashdot/slashdot"
       }
       ListElement {
           name: "OSnews"
           url: "http://www.osnews.com/files/recent.xml"
       }
    }

    PlasmaCore.DataSource {
        id: dataSource
        engine: "rss"
        interval: 50000
    }

    property Component firstPage: Page{
        id: pageComponent

        title: "News reader"
        ListView {
            anchors.fill: parent
            model: rssList
            delegate: BasicListItem {
                title: name
                onClicked: {
                    //secondPage.title = name
                    dataSource.source = url
                    window.nextPage(secondPage);
                }
            }

            PositionIndicator { }
        }
    }

    property Component secondPage: Page {
        title: dataSource.data['title'];

        ListView {
            id: postList
            anchors.fill: parent
            model: dataSource.data['items']
            delegate: BasicListItem {
                title: model.modelData.title
                onClicked: {
                    currentBody = "<body style=\"background:#fff;\">"+dataSource.data['items'][postList.currentIndex].description+"</body>";
                    currentTitle = model.modelData.title
                    currentUrl = model.modelData.link
                    window.nextPage(thirdPage);
                }
            }

            PositionIndicator { }
        }
    }

    property Component thirdPage: Page {
        title: currentTitle;
        actions: [
            Action {
                id: backAction
                iconId: "icon-m-toolbar-previous"
                onTriggered: { bodyView.html = currentBody }
                interactive: false
            },
            Action {
                id: linkAction
                iconId: "icon-l-browser"
                onTriggered: { bodyView.url = Url(currentUrl) }
                interactive: true
            }
        ]
        PlasmaWidgets.WebView {
            id : bodyView
            html: currentBody;
            anchors.fill: parent
            dragToScroll : true

            onUrlChanged: {
                backAction.interactive = (url != "about:blank")
                linkAction.interactive = (url != currentUrl)
            }
            onLoadProgress: {
                progressBar.visible = true
                progressBar.value = percent
            }
            onLoadFinished: {
                progressBar.visible = false
            }

            ProgressBar {
                id: progressBar
                minimum: 0
                maximum: 100
                anchors.left: bodyView.left
                anchors.right: bodyView.right
                anchors.bottom: bodyView.bottom
            }
        }
    }

    Component.onCompleted: {
        window.nextPage(firstPage)
    }
}