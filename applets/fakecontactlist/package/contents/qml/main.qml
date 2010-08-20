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

      Plasma.Theme {
          id: theme
      }

      resources: [
          Component {
              id: simpleText
              Item {
                id : background
                width: list.width
                height: frame.height

                Plasma.Frame {
                    id:frame
                    width:list.width
                    //minimumSize: "0x"+background.height
                    layout: QGraphicsLinearLayout {
                        Plasma.IconWidget {
                            orientation: Qt.Horizontal
                            text: name
                            infoText: status
                            Component.onCompleted: setIcon("user-"+status)
                        }
                    }
                }


                MouseArea {
                    id: itemMouse
                    anchors.fill: background
                    onClicked: {
                        list.currentIndex = index
                        list.itemClicked()
                        userStatus.setIcon("user-"+status)
                        userStatus.text = name
                        userStatus.infoText = status
                        if (status == "offline") {
                            chatButton.visible = false
                        } else {
                            chatButton.visible = true
                        }
                    }
                }
              }
          }
      ]

      ContactsModel {
          id: contactsModel
      }

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
                    snapMode: ListView.SnapToItem
                    spacing: 5;

                    clip: true
                    model: contactsModel
                    delegate: simpleText
                }
            }
            QGraphicsWidget {

                layout: QGraphicsGridLayout {
                    QGraphicsWidget {
                        layout: QGraphicsLinearLayout {
                            Plasma.PushButton {
                                id: showAllButton
                                text: "Show all"
                                onClicked: mainView.currentIndex = 0
                            }

                            Plasma.IconWidget {
                                id: userStatus
                                orientation: Qt.Horizontal
                            }
                        }
                        QGraphicsGridLayout.row: 0
                        QGraphicsGridLayout.column: 0
                        QGraphicsGridLayout.columnSpan:2
                    }

                    Plasma.PushButton {
                        text: "Call"
                        QGraphicsGridLayout.row: 1
                        QGraphicsGridLayout.column: 0
                    }
                    Plasma.PushButton {
                        text: "SMS"
                        QGraphicsGridLayout.row: 1
                        QGraphicsGridLayout.column: 1
                    }
                    Plasma.PushButton {
                        text: "Mail"
                        QGraphicsGridLayout.row: 2
                        QGraphicsGridLayout.column: 0
                    }
                    Plasma.PushButton {
                        id: chatButton
                        text: "Chat"
                        QGraphicsGridLayout.row: 2
                        QGraphicsGridLayout.column: 1
                    }
                }
            }
        }

        Connections {
            target: list
            onItemClicked: {
                mainView.currentIndex = 1
            }
        }
    }
}
