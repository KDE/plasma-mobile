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
    id: mainWidget

    property int currentIndex: list.currentIndex

    signal itemClicked
    signal newClicked

    Item {
        id: main
        width: mainWidget.width
        height: mainWidget.height

        PlasmaCore.Theme {
            id: theme
        }

        Component {
            id : messageDelegate
            PlasmaCore.FrameSvgItem {
                id: delegateItem
                imagePath: "widgets/frame"
                prefix: "plain"
                width: list.width
                height: delegateLayout.height+5

                Column {
                    id : delegateLayout
                    spacing: 5

                    Text {
                        color: theme.textColor
                        text: subject
                    }
                    Text {
                        color: theme.textColor
                        text: from
                    }
                }

                MouseArea {
                    id: itemMouse
                    anchors.fill: delegateItem
                    onClicked: {
                        list.currentIndex = index
                        mainWidget.itemClicked()
                    }
                }
            }
        }


        PlasmaWidgets.Frame {
            id: frame
            anchors.left: parent.left
            anchors.right: parent.right
            frameShadow : "Raised"

            layout : GraphicsLayouts.QGraphicsLinearLayout {
                PlasmaWidgets.PushButton {
                    //FIXME: either icons should be accessible by name or bindings for KIcon would be neede
                    //icon: "mail-message-new"
                    text: "Write"
                    onClicked : mainWidget.newClicked()
                }
                PlasmaWidgets.PushButton {
                    //icon: "mail-receive"
                    text: "Check"
                }
    
                QGraphicsWidget{}

                PlasmaWidgets.LineEdit {
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
            spacing: 5;
            clip: true
            model: model
            delegate: messageDelegate
        }
        
    }

}