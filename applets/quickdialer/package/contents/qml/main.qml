/*
 *   Copyright 2010 Alexis Menard <menard@kde.org>
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
import org.kde.plasma.phone 0.1 as PlasmaPhone
import org.kde.plasma.graphicslayouts 4.7 as GraphicsLayouts

QGraphicsWidget {
    id: main
    Item { PlasmaPhone.Phone { id : phone} }
    function enterDigit(digit)
    {
        if (number.text == "Please type a number")
            number.text = digit
        else
            number.text = number.text + digit
    }

    function call()
    {
      if (number.text == "Please type a number")
        return
      phone.call(number.text);
    }

    function deleteLastDigit()
    {
        number.text = number.text.slice(0, -1)
        if (number.text.length == 0)
          number.text = "Please type a number"
    }
    onWidthChanged : {
        if (width > height) {
            box.orientation = Qt.Horizontal
        } else {
            displayLayoutItem.height = 300
            box.orientation = Qt.Vertical
        }
    }

    layout: GraphicsLayouts.QGraphicsLinearLayout {
            id: box;
            spacing : 10
            orientation: Qt.Horizontal
            contentsMargin: 42

            LayoutItem{
                id: displayLayoutItem
                minimumSize: "200x200"
                preferredSize: number.width+"x35"
                //minimumSize: "300x0"
                //maximumSize: "100x35" 
                //maximumSize: "1000x35"
                Rectangle {
                    id : display
                    width : parent.width
                    height : parent.height
                    color : Qt.rgba(0,0,0,0.4);
                    anchors.fill: parent
                    clip: true
                    Text {
                        id : number;
                        font.bold : true;
                        font.pixelSize : 40;
                        anchors.left : parent.left;
                        anchors.right : parent.right;
                        anchors.verticalCenter : parent.verticalCenter
                        color : "white";
                        wrapMode : Text.Wrap
                        horizontalAlignment : TextInput.AlignHCenter
                        text : "Please type a number"
                    }
                }
            }

            GraphicsLayouts.QGraphicsGridLayout{
                property int r: 0
                property int c: 0
                id: grid
                spacing: 10

                PlasmaWidgets.PushButton { GraphicsLayouts.QGraphicsGridLayout.row: 0; GraphicsLayouts.QGraphicsGridLayout.column: 0; text: "1"; onClicked: enterDigit("1");}
                PlasmaWidgets.PushButton { GraphicsLayouts.QGraphicsGridLayout.row: 0; GraphicsLayouts.QGraphicsGridLayout.column: 1;  text: "2"; onClicked: enterDigit("2");}
                PlasmaWidgets.PushButton { GraphicsLayouts.QGraphicsGridLayout.row: 0; GraphicsLayouts.QGraphicsGridLayout.column: 2; text: "3"; onClicked: enterDigit("3");}
                PlasmaWidgets.PushButton { GraphicsLayouts.QGraphicsGridLayout.row: 1; GraphicsLayouts.QGraphicsGridLayout.column: 0; text: "4"; onClicked: enterDigit("4");}
                PlasmaWidgets.PushButton { GraphicsLayouts.QGraphicsGridLayout.row: 1; GraphicsLayouts.QGraphicsGridLayout.column: 1; text: "5"; onClicked: enterDigit("5");}
                PlasmaWidgets.PushButton { GraphicsLayouts.QGraphicsGridLayout.row: 1; GraphicsLayouts.QGraphicsGridLayout.column: 2; text: "6"; onClicked: enterDigit("6");}
                PlasmaWidgets.PushButton { GraphicsLayouts.QGraphicsGridLayout.row: 2; GraphicsLayouts.QGraphicsGridLayout.column: 0; text: "7"; onClicked: enterDigit("7");}
                PlasmaWidgets.PushButton { GraphicsLayouts.QGraphicsGridLayout.row: 2; GraphicsLayouts.QGraphicsGridLayout.column: 1; text: "8"; onClicked: enterDigit("8");}
                PlasmaWidgets.PushButton { GraphicsLayouts.QGraphicsGridLayout.row: 2; GraphicsLayouts.QGraphicsGridLayout.column: 2; text: "9"; onClicked: enterDigit("9");}
                PlasmaWidgets.PushButton { GraphicsLayouts.QGraphicsGridLayout.row: 3; GraphicsLayouts.QGraphicsGridLayout.column: 0; text: "*"; onClicked: enterDigit("*");}
                PlasmaWidgets.PushButton { GraphicsLayouts.QGraphicsGridLayout.row: 3; GraphicsLayouts.QGraphicsGridLayout.column: 1; text: "0"; onClicked: enterDigit("0");}
                PlasmaWidgets.PushButton { GraphicsLayouts.QGraphicsGridLayout.row: 3; GraphicsLayouts.QGraphicsGridLayout.column: 2; text: "#"; onClicked: enterDigit("#");}
                PlasmaWidgets.PushButton { GraphicsLayouts.QGraphicsGridLayout.row: 4; GraphicsLayouts.QGraphicsGridLayout.column: 0; GraphicsLayouts.QGraphicsGridLayout.columnSpan: 2; text: "Call"; onClicked: call();}
                PlasmaWidgets.PushButton { GraphicsLayouts.QGraphicsGridLayout.row: 4; GraphicsLayouts.QGraphicsGridLayout.column: 2; GraphicsLayouts.QGraphicsGridLayout.columnSpan: 1; text: "Del"; onClicked: deleteLastDigit();}
            }
    }
}
