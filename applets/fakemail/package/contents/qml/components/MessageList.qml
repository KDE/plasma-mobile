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
import GraphicsLayouts 4.7
import Plasma 0.1 as Plasma

QGraphicsWidget {
    id: mainWidget

    property int currentIndex: list.currentIndex

    signal itemClicked
    signal newClicked

    Item {
        id: main
        width: mainWidget.width
        height: mainWidget.height

        Component {
            id : messageDelegate
            Item {
                width: list.width
                height: layout.height

                Rectangle {
                    id : background
                    anchors.fill : parent

                    Column {
                        id : layout

                        Text {
                            text: subject
                        }
                        Text {
                            text: from
                        }
                    }

                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "transparent" }
                        GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.15)  }
                    }
                }
                MouseArea {
                    id: itemMouse
                    anchors.fill: parent
                    onClicked: {
                        list.currentIndex = index
                        mainWidget.itemClicked()
                    }
                }
            }
        }


        Plasma.Frame {
            id: frame
            anchors.left: parent.left
            anchors.right: parent.right
            frameShadow : "Raised"

            layout : QGraphicsLinearLayout {
                Plasma.PushButton {
                    //FIXME: either icons should be accessible by name or bindings for KIcon would be neede
                    //icon: "mail-message-new"
                    text: "Write"
                    onClicked : mainWidget.newClicked()
                }
                Plasma.PushButton {
                    //icon: "mail-receive"
                    text: "Check"
                }
    
                QGraphicsWidget{}

                Plasma.LineEdit {
                    clickMessage: "Search..."
                    clearButtonShown: true
                }
            }
        }

        MessagesModel {
            id: model
        }

        ListView {
            id: list
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.top: frame.bottom
            clip: true
            model: model
            delegate: messageDelegate
        }
        
    }

}