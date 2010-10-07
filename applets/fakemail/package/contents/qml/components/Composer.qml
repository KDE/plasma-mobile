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
    id: root;

    signal backClicked
    signal sendClicked

    property string subjectText: ""
    property string bodyText: ""
    property string toText: ""


    PlasmaWidgets.Frame {
        id: frame
        anchors.left: parent.left
        anchors.right: parent.right
        frameShadow : "Raised"

        layout: GraphicsLayouts.QGraphicsGridLayout {
            id : lay

            PlasmaWidgets.PushButton {
                GraphicsLayouts.QGraphicsGridLayout.row : 0
                GraphicsLayouts.QGraphicsGridLayout.column : 0
                GraphicsLayouts.QGraphicsGridLayout.columnMaximumWidth : 30
                text: "Back"
                onClicked: {
                    root.backClicked()
                }
            }


            PlasmaWidgets.PushButton {
                id: fromButton
                GraphicsLayouts.QGraphicsGridLayout.row : 0
                GraphicsLayouts.QGraphicsGridLayout.column : 1
                text: "John"
            }

            PlasmaWidgets.LineEdit {
                minimumSize.height : fromButton.size.height
                GraphicsLayouts.QGraphicsGridLayout.row : 0
                GraphicsLayouts.QGraphicsGridLayout.column : 2
                GraphicsLayouts.QGraphicsGridLayout.columnSpan : 2
                //QGraphicsGridLayout.alignment : QGraphicsGridLayout.Center
                text: root.subjectText
            }



            PlasmaWidgets.PushButton {
                id: toButton
                GraphicsLayouts.QGraphicsGridLayout.row : 1
                GraphicsLayouts.QGraphicsGridLayout.column : 1
                text: "To:"
            }
            PlasmaWidgets.LineEdit {
                minimumSize.height : toButton.size.height
                GraphicsLayouts.QGraphicsGridLayout.row : 1
                GraphicsLayouts.QGraphicsGridLayout.column : 2
                GraphicsLayouts.QGraphicsGridLayout.columnStretchFactor : 3
                text: root.toText
            }
            PlasmaWidgets.PushButton {
                GraphicsLayouts.QGraphicsGridLayout.row : 1
                GraphicsLayouts.QGraphicsGridLayout.column : 3
                text: "Send"
                onClicked: {
                    root.sendClicked()
                }
            }
        }
    }

    Item {
        PlasmaCore.Theme {
            id: theme
        }
    }

    PlasmaWidgets.WebView {
        id : text
        
        anchors.left: parent.left
        anchors.leftMargin: 60
        anchors.right: parent.right
        anchors.top : frame.bottom
        anchors.bottom : parent.bottom
        width : parent.width - 60
        dragToScroll : true
        html: "<div contenteditable=\"true\" style=\"color:"+theme.textColor+"\">"+root.bodyText+"</div>"
    }


    PlasmaWidgets.PushButton {
        id : buttonA
        anchors.left: parent.left
        anchors.top: parent.bottom
        text: "A"
        rotation : -90
    }
    PlasmaWidgets.PushButton {
        id : buttonActions
        anchors.left: parent.left
        anchors.bottom: buttonA.top
        anchors.bottomMargin : 25
        text: "Actions"
        rotation : -90
    }
}