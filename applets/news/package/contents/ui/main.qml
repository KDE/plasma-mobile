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
import org.kde.plasma.graphicswidgets 0.1 as PlasmaWidgets
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.graphicslayouts 4.7 as GraphicsLayouts

import "plasmapackage:/code/utils.js" as Utils
import "plasmapackage:/code/bookkeeping.js" as BookKeeping

QGraphicsWidget {
    id: mainWindow;
    preferredSize: "250x600"
    minimumSize: "200x200"

    property string source
    signal unreadCountChanged();

    Component.onCompleted: {
        BookKeeping.loadReadArticles();
        plasmoid.addEventListener('ConfigChanged', configChanged);
        plasmoid.busy = true
    }

    function configChanged()
    {
        source = plasmoid.readConfig("feeds")
        var sourceString = new String(source)
        print("Configuration changed: " + source);
        feedSource.source = source
    }

    Item {
        PlasmaCore.DataSource {
            id: feedSource
            engine: "rss"
            interval: 50000
            onDataChanged: {
                plasmoid.busy = false
                BookKeeping.updateUnreadCount(data.items)
            }
        }

        PlasmaCore.Theme {
            id: theme
        }

        Timer {
            id: searchTimer
            interval: 500;
            running: false
            repeat: false
            onTriggered: {
                if (mainView.currentIndex == 0) {
                    feedListFilter.filterRegExp = ".*"+searchBox.text+".*";
                } else {
                    postTitleFilter.filterRegExp = ".*"+searchBox.text+".*";
                }
            }
        }
    }

    layout: GraphicsLayouts.QGraphicsLinearLayout {
        orientation: "Vertical"
        PlasmaWidgets.Frame {
            maximumSize: maximumSize.width+"x"+minimumSize.height
            frameShadow: "Raised"
            layout: GraphicsLayouts.QGraphicsLinearLayout {
                PlasmaWidgets.PushButton {
                    id: backButton
                    text: i18n("Back")
                    maximumSize: minimumSize

                    onClicked: {
                        if (!bodyView.customUrl) {
                            mainView.currentIndex = mainView.currentIndex -1
                        } else {
                            bodyView.html = "<body style=\"background:#fff;\">"+feedSource.data['items'][list.currentIndex].description+"</body>";
                        }
                    }
                }
                QGraphicsWidget {
                    GraphicsLayouts.QGraphicsLinearLayout.stretchFactor: 2
                }
                PlasmaWidgets.LineEdit {
                    id: searchBox
                    clearButtonShown: true
                    onTextEdited: {
                        searchTimer.running = true
                    }
                }
            }
        }

        PlasmaWidgets.TabBar {
            id : mainView
            width : mainWindow.width
            height: mainWindow.height
            tabBarShown: false

            onCurrentChanged: {
                backButton.visible = currentIndex > 0
                searchBox.visible = currentIndex < 2
            }

            QGraphicsWidget {
                id: feedListContainer
                ListView {
                    id: feedList
                    anchors.fill: feedListContainer
                    signal itemClicked;
                    spacing: 5;
                    snapMode: ListView.SnapToItem

                    clip: true
                    model: PlasmaCore.SortFilterModel {
                        id: feedListFilter
                        filterRole: "feed_title"
                        sourceModel: PlasmaCore.DataModel {
                            dataSource: feedSource
                            key: "sources"
                        }
                    }

                    header: Column {
                        ListItemSource {
                            id: feedListHeader
                            text: i18n("Show All")
                            unread: BookKeeping.totalUnreadCount
                            onClicked: {
                                feedCategoryFilter.filterRegExp = ""
                                mainView.currentIndex = 1
                            }
                            Connections {
                                target: mainWindow
                                onUnreadCountChanged: {
                                    feedListHeader.unread = BookKeeping.totalUnreadCount
                                }
                            }
                        }
                        Item {
                            height: 5
                            width: 5
                        }
                    }
                    delegate: ListItemSource {
                        id: listItemSource
                        text: feed_title
                        icon: model.icon
                        unread: BookKeeping.unreadForSource(feed_url)

                        onClicked: {
                            feedCategoryFilter.filterRegExp = feed_url
                            mainView.currentIndex = 1
                        }
                        Connections {
                            target: mainWindow
                            onUnreadCountChanged: {
                                unread = BookKeeping.unreadForSource(feed_url)
                            }
                        }
                    }
                }
            }
            QGraphicsWidget {
                id: listContainer
                Component.onCompleted: {
                    mainView.currentIndex = 1
                }

                ListView {
                    id: list
                    anchors.fill: listContainer
                    spacing: 5;
                    snapMode: ListView.SnapToItem

                    clip: true
                    model: PlasmaCore.SortFilterModel {
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

                    section.property: "feed_title"
                    section.criteria: ViewSection.FullString
                    section.delegate: ListItem {
                        Text {
                            text: section
                            font.bold: true
                        }
                    }

                    delegate: ListItemEntry {
                        text: title
                        date: Utils.date(time)

                        Component.onCompleted: {
                            if (BookKeeping.isArticleRead(link)) {
                                opacity = 0.5
                            } else {
                                opacity = 1
                            }
                        }

                        onClicked: {
                            BookKeeping.setArticleRead(link, feed_url);
                            opacity = 0.5;

                            list.currentIndex = index
                            bodyView.html = "<body style=\"background:#fff;\">"+description+"</body>"
                            mainView.currentIndex = 2
                        }
                    }
                }
            }

            PlasmaWidgets.WebView {
                id : bodyView
                dragToScroll : true
                property bool customUrl: false
                onUrlChanged: {
                    customUrl = (url != "about:blank")
                }
            }
        }
    }
}
