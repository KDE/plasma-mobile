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
    Item {
      id:main
      Plasma.DataSource { id: dataSource; engine: "rss"; source: "http://planetkde.org/rss20.xml"; interval: 50000; }

      Plasma.Theme {
          id: theme
      }

      resources: [
          Component {
              id: simpleText
              Rectangle {
                  id : background
                  width: list.width
                  height: delegateLayout.height

                  Column {
                      id : delegateLayout

                      Text {
                          color: theme.textColor
                          text: dataSource['items'][modelData].title
                      }
                      Text {
                          color: theme.textColor
                          text: dataSource['items'][modelData].time
                      }
                  }

                  gradient: Gradient {
                      GradientStop { position: 0.0; color: "transparent" }
                      GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.08)  }
                  }

                  MouseArea {
                      id: itemMouse
                      anchors.fill: parent
                      onClicked: {
                          list.currentIndex = index
                          bodyView.html = dataSource['items'][modelData].description
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

                    clip: true
                    model: dataSource['items.count']
                    delegate: simpleText
                }
            }
            QGraphicsWidget {
                layout: QGraphicsLinearLayout {
                    orientation: "Vertical"
                    Plasma.Frame {
                        frameShadow: "Raised"
                        layout: QGraphicsLinearLayout {
                            Plasma.PushButton {
                                id: showAllButton
                                text: "Show all"
                            }
                            Plasma.PushButton {
                                id: backButton
                                text: "Back"
                                visible:false
                                signal clicked
                            }
                            QGraphicsWidget {}
                        }
                    }
                    Plasma.WebView {
                        id : bodyView
                        dragToScroll : true
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
