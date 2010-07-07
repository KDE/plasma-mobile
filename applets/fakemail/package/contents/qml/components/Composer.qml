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
    id: root;

    signal backClicked
    signal sendClicked

    property string subjectText: ""
    property string bodyText: ""
    property string toText: ""

    Plasma.Frame {
        id: frame
        anchors.left: parent.left
        anchors.right: parent.right
        frameShadow : "Raised"

        layout: QGraphicsGridLayout {
            id : lay

            Plasma.PushButton {
                QGraphicsGridLayout.row : 0
                QGraphicsGridLayout.column : 0
                QGraphicsGridLayout.columnMaximumWidth : 30
                text: "Back"
                onClicked: {
                    root.backClicked()
                }
            }


            Plasma.PushButton {
                id: fromButton
                QGraphicsGridLayout.row : 0
                QGraphicsGridLayout.column : 1
                text: "John"
            }

            Plasma.LineEdit {
                minimumSize.height : fromButton.size.height
                QGraphicsGridLayout.row : 0
                QGraphicsGridLayout.column : 2
                QGraphicsGridLayout.columnSpan : 2
                //QGraphicsGridLayout.alignment : QGraphicsGridLayout.Center
                text: root.subjectText
            }



            Plasma.PushButton {
                id: toButton
                QGraphicsGridLayout.row : 1
                QGraphicsGridLayout.column : 1
                text: "To:"
            }
            Plasma.LineEdit {
                minimumSize.height : toButton.size.height
                QGraphicsGridLayout.row : 1
                QGraphicsGridLayout.column : 2
                QGraphicsGridLayout.columnStretchFactor : 3
                text: root.toText
            }
            Plasma.PushButton {
                QGraphicsGridLayout.row : 1
                QGraphicsGridLayout.column : 3
                text: "Send"
                onClicked: {
                    root.sendClicked()
                }
            }
        }
    }


    Plasma.WebView {
        id : text
        anchors.left: parent.left
        anchors.leftMargin: 60
        anchors.right: parent.right
        anchors.top : frame.bottom
        anchors.bottom : parent.bottom
        width : parent.width - 60
        dragToScroll : true
        html: "<div contenteditable=\"true\">"+root.bodyText+"</div>"
    }


    Plasma.PushButton {
        id : buttonA
        anchors.left: parent.left
        anchors.top: parent.bottom
        text: "A"
        rotation : -90
    }
    Plasma.PushButton {
        id : buttonActions
        anchors.left: parent.left
        anchors.bottom: buttonA.top
        anchors.bottomMargin : 25
        text: "Actions"
        rotation : -90
    }
}