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


QGraphicsWidget {
    id: page;
    preferredSize: "250x600"
    minimumSize: "200x200"

    Component.onCompleted: {
        print(plasmoid['addEventListener'])
        plasmoid.addEventListener('ConfigChanged', configChanged);
    }

    function configChanged()
    {
        var url = plasmoid.readConfig("feeds")
        print("Configuration changed: " + url);
        dataSource.source = url
    }

    Item {
      id:main

      PlasmaCore.DataSource {
          id: dataSource
          engine: "rss"
          interval: 50000
      }

      PlasmaCore.Theme {
          id: theme
      }

      resources: [
          Component {
              id: simpleText
              PlasmaCore.FrameSvgItem {
                id : background
                imagePath: "widgets/frame"
                prefix: "plain"

                width: list.width
                height: delegateLayout.height + 5

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

        PlasmaWidgets.TabBar {
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
            onItemClicked: mainView.currentIndex = 1
        }
        Connections {
            target: showAllButton
            onClicked: mainView.currentIndex = 0
        }
    }
}
