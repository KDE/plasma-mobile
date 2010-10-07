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
    property int currentIndex: 0

    signal replyClicked
    signal forwardClicked
    signal backClicked

    property string subjectText: ""
    property string bodyText: ""
    property string fromText: ""

    Item {
        id : main
        anchors.fill : mainWidget

        PlasmaCore.Theme {
            id: theme
        }

        Component {
                id : messageDelegate

                Item {
                    id: content
                    width: mainView.width
                    height: mainView.height


                    PlasmaWidgets.WebView {
                        id : bodyView
                        width : content.width
                        height: content.height
                        dragToScroll : true
                        html: "<body style=\"color:"+theme.textColor+"\"><div style=\"border:1px solid #aaa; background: rgba(0,0,0,0.15)\">Subject:"+subject+"<br/>From:"+from+"</div>"+body+"</body>"
                    }
                }
            }

        MessagesModel {
            id: model
        }

        PlasmaWidgets.Frame {
            id: toolBar
            width: main.width
            frameShadow : "Raised"

            layout: GraphicsLayouts.QGraphicsLinearLayout {
                PlasmaWidgets.PushButton {
                    text: "Back"
                    onClicked: {
                        mainWidget.backClicked()
                    }
                }
                PlasmaWidgets.PushButton {
                    text: "Reply"
                    onClicked: {
                        mainWidget.subjectText = model.get(mainView.currentIndex).subject
                        mainWidget.bodyText = model.get(mainView.currentIndex).body
                        mainWidget.fromText = model.get(mainView.currentIndex).from
                        mainWidget.replyClicked()
                    }
                }
                PlasmaWidgets.PushButton {
                    text: "Forward"
                    onClicked: {
                        mainWidget.forwardClicked()
                    }
                }
                QGraphicsWidget{}
            }
        }

        ListView {
            id : mainView
            anchors.top : toolBar.bottom
            anchors.bottom: main.bottom
            anchors.left: main.left
            anchors.right: main.right

            /*contentWidth: content.width
            contentHeight: content.height*/
            highlightRangeMode: ListView.StrictlyEnforceRange
            clip : true
            orientation: ListView.Horizontal
            snapMode: ListView.SnapOneItem

            model: model

            delegate: messageDelegate
            currentIndex: mainWidget.currentIndex

            /*Connections {
                target: messageList
                onItemClicked: mainView.currentIndex = 1
                onNewClicked: mainView.currentIndex = 1
            }*/
        }
    }
}
