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
    id: page;
    preferredSize: "250x600"
    minimumSize: "200x200"

    Component.onCompleted: {
        BookKeeping.loadReadArticles();
        print(plasmoid['addEventListener'])
        plasmoid.addEventListener('ConfigChanged', configChanged);
    }

    function configChanged()
    {
        var source = plasmoid.readConfig("feeds")
        var sourceString = new String(source)
        print("Configuration changed: " + source);
        dataSource.source = source

        feedListModel.append({"text": i18n("Show All"), "url": source});
        var urls = sourceString.split(" ")

        for (var i=0; i < urls.length; ++i) {
            var url = urls[i]
            feedListModel.append({"text": url, "url": url});
        }
    }

    Item {
      id:main

      ListModel {
          id: feedListModel
      }

      PlasmaCore.DataSource {
          id: dataSource
          engine: "rss"
          interval: 50000
      }

      PlasmaCore.Theme {
          id: theme
      }

        PlasmaWidgets.TabBar {
            id : mainView
            width : page.width
            height: page.height
            tabBarShown: false

            QGraphicsWidget {
                id: feedListContainer
                ListView {
                    id: feedList
                    anchors.fill: feedListContainer
                    signal itemClicked;
                    spacing: 5;
                    snapMode: ListView.SnapToItem

                    clip: true
                    model: feedListModel
                    delegate: Text {
                        text: model.text
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                dataSource.source = model.url
                                mainView.currentIndex = 1
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


                PlasmaWidgets.Frame {
                    id: listContainerToolbar
                    anchors.left: listContainer.left
                    anchors.right: listContainer.right
                    maximumSize: maximumSize.width+"x"+minimumSize.height
                    frameShadow: "Raised"
                    layout: GraphicsLayouts.QGraphicsLinearLayout {
                        PlasmaWidgets.PushButton {
                            id: listButton
                            maximumSize: minimumSize
                            text: i18n("Feed List")

                            onClicked: {
                                mainView.currentIndex = 0;
                            }
                        }

                        QGraphicsWidget {}
                    }
                }

                ListView {
                    id: list
                    anchors.left: listContainer.left
                    anchors.right: listContainer.right
                    anchors.top: listContainerToolbar.bottom
                    anchors.bottom: listContainer.bottom
                    signal itemClicked;
                    spacing: 5;
                    snapMode: ListView.SnapToItem

                    clip: true
                    model: dataSource.data['items']
                    delegate: ListItem {
                        text: model.modelData.title
                        date: Utils.date(model.modelData.time)

                        Component.onCompleted: {
                            if (BookKeeping.isArticleRead(model.modelData.link)) {
                                opacity = 0.5
                            } else {
                                opacity = 1
                            }
                        }

                        onClicked: {
                            BookKeeping.setArticleRead(model.modelData.link);
                            opacity = 0.5;

                            list.currentIndex = index
                            bodyView.html = "<body style=\"background:#fff;\">"+model.modelData.description+"</body>"
                            list.itemClicked()
                        }
                    }
                }
            }
            QGraphicsWidget {
                layout: GraphicsLayouts.QGraphicsLinearLayout {
                    orientation: "Vertical"
                    PlasmaWidgets.Frame {
                        maximumSize: maximumSize.width+"x"+minimumSize.height
                        frameShadow: "Raised"
                        layout: GraphicsLayouts.QGraphicsLinearLayout {
                            PlasmaWidgets.PushButton {
                                id: showAllButton
                                maximumSize: minimumSize
                                text: "Show all"
                            }
                            PlasmaWidgets.PushButton {
                                id: backButton
                                text: "Back"
                                visible:false
                                maximumSize: minimumSize
                                onClicked: {
                                    bodyView.html = "<body style=\"background:#fff;\">"+dataSource.data['items'][list.currentIndex].description+"</body>";
                                    visible = false;
                                }
                            }
                            QGraphicsWidget {}
                        }
                    }
                    PlasmaWidgets.WebView {
                        id : bodyView
                        dragToScroll : true
                        onUrlChanged: {
                            if (url != "about:blank") {
                                backButton.visible = true
                            }
                        }
                    }
                }
            }
        }

        Connections {
            target: list
            onItemClicked: mainView.currentIndex = 2
        }
        Connections {
            target: showAllButton
            onClicked: mainView.currentIndex = 1
        }
    }
}
