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
import Plasma 0.1 as Plasma
import GraphicsLayouts 4.7

QGraphicsWidget {
    id: main
    Item { Plasma.Phone { id : phone} }
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
            box.orientation = Qt.Vertical
        }
    }

    layout: QGraphicsLinearLayout {
            id: box;
            spacing : 10
            orientation: Qt.Horizontal
            contentsMargin: 42

            LayoutItem{
                minimumSize: "300x300"
                preferredSize: number.width+"x35"
                //maximumSize: "1000x35"
                Rectangle {
                    id : display
                    width : parent.width
                    height : parent.height
                    color : Qt.rgba(0,0,0,0.4);
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

            QGraphicsGridLayout{
                property int r: 0
                property int c: 0
                id: grid;  spacing: 10
                
                Plasma.PushButton { QGraphicsGridLayout.row: 0; QGraphicsGridLayout.column: 0; QGraphicsGridLayout.columnSpan: 2; text: "1"; onClicked: enterDigit("1");}
                Plasma.PushButton { QGraphicsGridLayout.row: 0; QGraphicsGridLayout.column: 2; QGraphicsGridLayout.columnSpan: 2;  text: "2"; onClicked: enterDigit("2");}
                Plasma.PushButton { QGraphicsGridLayout.row: 0; QGraphicsGridLayout.column: 4; QGraphicsGridLayout.columnSpan: 2; text: "3"; onClicked: enterDigit("3");}
                Plasma.PushButton { QGraphicsGridLayout.row: 1; QGraphicsGridLayout.column: 0; QGraphicsGridLayout.columnSpan: 2; text: "4"; onClicked: enterDigit("4");}
                Plasma.PushButton { QGraphicsGridLayout.row: 1; QGraphicsGridLayout.column: 2; QGraphicsGridLayout.columnSpan: 2; text: "5"; onClicked: enterDigit("5");}
                Plasma.PushButton { QGraphicsGridLayout.row: 1; QGraphicsGridLayout.column: 4; QGraphicsGridLayout.columnSpan: 2; text: "6"; onClicked: enterDigit("6");}
                Plasma.PushButton { QGraphicsGridLayout.row: 2; QGraphicsGridLayout.column: 0; QGraphicsGridLayout.columnSpan: 2; text: "7"; onClicked: enterDigit("7");}
                Plasma.PushButton { QGraphicsGridLayout.row: 2; QGraphicsGridLayout.column: 2; QGraphicsGridLayout.columnSpan: 2; text: "8"; onClicked: enterDigit("8");}
                Plasma.PushButton { QGraphicsGridLayout.row: 2; QGraphicsGridLayout.column: 4; QGraphicsGridLayout.columnSpan: 2; text: "9"; onClicked: enterDigit("9");}
                Plasma.PushButton { QGraphicsGridLayout.row: 3; QGraphicsGridLayout.column: 0; QGraphicsGridLayout.columnSpan: 2; text: "*"; onClicked: enterDigit("*");}
                Plasma.PushButton { QGraphicsGridLayout.row: 3; QGraphicsGridLayout.column: 2; QGraphicsGridLayout.columnSpan: 2; text: "0"; onClicked: enterDigit("0");}
                Plasma.PushButton { QGraphicsGridLayout.row: 3; QGraphicsGridLayout.column: 4; QGraphicsGridLayout.columnSpan: 2; text: "#"; onClicked: enterDigit("#");}
                Plasma.PushButton { QGraphicsGridLayout.row: 4; QGraphicsGridLayout.column: 0; QGraphicsGridLayout.columnSpan: 3; text: "Call"; onClicked: call();}
                Plasma.PushButton { QGraphicsGridLayout.row: 4; QGraphicsGridLayout.column: 3; QGraphicsGridLayout.columnSpan: 3; text: "Del"; onClicked: deleteLastDigit();}
            }
            
    }
}
