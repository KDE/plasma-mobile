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
import Plasma 0.1 as Plasma
import GraphicsLayouts 4.7

QGraphicsWidget {
    id: page;
    preferredSize: "250x600"
    minimumSize: "200x200"
    Item {
      id:main

      Plasma.DataSource {
          id: dataSource
          engine: "rss"
          source: "http://planetkde.org/rss20.xml"
          interval: 50000
      }

      Plasma.Theme {
          id: theme
      }

      resources: [
          Component {
              id: simpleText
              Item {
                id : background
                width: list.width
                height: delegateLayout.height + 5

                Plasma.Frame {
                    id:frame
                    width:list.width
                    minimumSize: "0x"+background.height
                }


                Column {
                    id : delegateLayout
                    width: list.width
                    spacing: 5

                    Text {
                        //width: list.width
                        color: theme.textColor
                        textFormat: Text.RichText
                        text: model.modelData.title
                    }
                    Text {
                        id: date
                        color: theme.textColor
                        width: list.width
                        horizontalAlignment: Text.AlignRight
                        text: '<em><small>'+Date(model.modelData.time)+'</em></small>&nbsp;'
                    }
                }

                MouseArea {
                    id: itemMouse
                    anchors.fill: background
                    onClicked: {
                        list.currentIndex = index
                        bodyView.html = "<body style=\"background:#fff;\">"+model.modelData.description+"</body>"
                        list.itemClicked()
                    }
                }
              }
          }
      ]

        Plasma.TabBar {
            id : mainView
            width : page.width
            height: page.height
            tabBarShown: false

            QGraphicsWidget {
                id: listContainer
                ListView {
                    id: list
                    anchors.fill: listContainer
                    signal itemClicked;
                    spacing: 5;
                    snapMode: ListView.SnapToItem

                    clip: true
                    model: dataSource.data['items']
                    delegate: simpleText
                }
            }
            QGraphicsWidget {
                layout: QGraphicsLinearLayout {
                    orientation: "Vertical"
                    Plasma.Frame {
                        maximumSize: maximumSize.width+"x"+minimumSize.height
                        frameShadow: "Raised"
                        layout: QGraphicsLinearLayout {
                            Plasma.PushButton {
                                id: showAllButton
                                maximumSize: minimumSize
                                text: "Show all"
                            }
                            Plasma.PushButton {
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
                    Plasma.WebView {
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
            onItemClicked: mainView.currentIndex = 1
        }
        Connections {
            target: showAllButton
            onClicked: mainView.currentIndex = 0
        }
    }
}
