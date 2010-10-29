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

import "plasmapackage:/code/utils.js" as Utils
import "plasmapackage:/code/bookkeeping.js" as BookKeeping

Window {
    id: mainWindow

    property string currentTitle;
    property string currentBody;
    property string currentUrl;

    signal unreadCountChanged();

    Component.onCompleted: {
        BookKeeping.loadReadArticles();
        plasmoid.addEventListener('ConfigChanged', configChanged);
        spinner.visible = true
        mainWindow.nextPage(firstPage)
    }

    function configChanged()
    {
        source = plasmoid.readConfig("feeds")
        var sourceString = new String(source)
        print("Configuration changed: " + source);
        feedSource.source = source
    }

    PlasmaCore.DataSource {
        id: feedSource
        engine: "rss"
        interval: 50000
        onDataChanged: {
            spinner.visible = false;
            BookKeeping.updateUnreadCount(data.items)
        }
    }

    PlasmaCore.SortFilterModel {
        id: postTitleFilter
        filterRole: "title"
        sortRole: "time"
        sortOrder: "DescendingOrder"
        sourceModel: PlasmaCore.SortFilterModel {
            id: feedCategoryFilter
            filterRole: "feed_url"
            sourceModel: PlasmaCore.DataModel {
                dataSource: feedSource
                key: "items"
            }
        }
    }


    property Component firstPage: Page{
        id: pageComponent

        title: "News reader"
        ListView {
            anchors.fill: parent
            model: PlasmaCore.SortFilterModel {
                        id: feedListFilter
                        filterRole: "feed_title"
                        sourceModel: PlasmaCore.DataModel {
                            dataSource: feedSource
                            key: "sources"
                        }
                    }
            header: BasicListItem {
                id: feedListHeader
                title: i18n("Show All")
                Label {
                    id: unreadLabelHeader
                    anchors.right: feedListHeader.padding.right
                    anchors.verticalCenter: feedListHeader.verticalCenter
                    text: BookKeeping.totalUnreadCount
                }
                onClicked: {
                    feedCategoryFilter.filterRegExp = ""
                    mainWindow.nextPage(secondPage);
                }
                Connections {
                    target: mainWindow
                    onUnreadCountChanged: {
                        unreadLabelHeader.text = BookKeeping.totalUnreadCount
                    }
                }
            }

            delegate: BasicListItem {
                id: feedListItem
                title: feed_title
                image: model.icon
                Label {
                    id: unreadLabel
                    anchors.right: feedListItem.padding.right
                    anchors.verticalCenter: feedListItem.verticalCenter
                    text: BookKeeping.unreadForSource(feed_url)
                }
                onClicked: {
                    feedCategoryFilter.filterRegExp = feed_url
                    mainWindow.nextPage(secondPage);
                }
                Connections {
                    target: mainWindow
                    onUnreadCountChanged: {
                        unreadLabel.text = BookKeeping.unreadForSource(feed_url)
                    }
                }
            }

            PositionIndicator { }
        }
    }

    property Component secondPage: Page {
        title: feedSource.data['title'];

        ListView {
            id: postList
            anchors.fill: parent
            model: postTitleFilter
            section.property: "feed_title"
            section.criteria: ViewSection.FullString
            section.delegate: Rectangle {
                width: postList.width
                height: childrenRect.height
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "white" }
                    GradientStop { position: 1.0; color: Qt.rgba(0.6, 0.6, 0.6, 1) }
                }
                Column {
                    Item {
                        width: 5
                        height: 5
                    }
                    Label {
                        x: 5
                        text: section
                        font.bold: true
                    }
                    Item {
                        width: 5
                        height: 5
                    }
                }
            }
            delegate: BasicListItem {
                title: model.title
                subtitle: Utils.date(model.time);
                onClicked: {
                    BookKeeping.setArticleRead(link, feed_url);
                    opacity = 0.5;

                    currentBody = "<body style=\"background:#fff;\">"+model.description+"</body>";
                    currentTitle = model.title
                    currentUrl = model.link
                    mainWindow.nextPage(thirdPage);
                }
                Component.onCompleted: {
                    if (BookKeeping.isArticleRead(link)) {
                        opacity = 0.5
                    } else {
                        opacity = 1
                    }
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

    Spinner {
        id: spinner
        unknownDuration: true
        visible: false
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
    }
}