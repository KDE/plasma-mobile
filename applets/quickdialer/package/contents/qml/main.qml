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
       
    Column {
            id: box;
            spacing : 10
            anchors { fill: parent; topMargin: 6; bottomMargin: 6; leftMargin: 6; rightMargin: 6 }
            Item {
                width : grid.width
                height : grid.height
                Grid {
                      property real w: (box.width / columns) - ((spacing * (columns - 1)) / columns)
                      id: grid; rows: 5; columns: 3; spacing: 6
                      Plasma.PushButton { width: grid.w; height: 60; text: "7"; onClicked: enterDigit("7");}
                      Plasma.PushButton { width: grid.w; height: 60; text: "8"; onClicked: enterDigit("8");}
                      Plasma.PushButton { width: grid.w; height: 60; text: "9"; onClicked: enterDigit("9");}
                      Plasma.PushButton { width: grid.w; height: 60; text: "4"; onClicked: enterDigit("5");}
                      Plasma.PushButton { width: grid.w; height: 60; text: "5"; onClicked: enterDigit("5");}
                      Plasma.PushButton { width: grid.w; height: 60; text: "6"; onClicked: enterDigit("6");}
                      Plasma.PushButton { width: grid.w; height: 60; text: "1"; onClicked: enterDigit("1");}
                      Plasma.PushButton { width: grid.w; height: 60; text: "2"; onClicked: enterDigit("2");}
                      Plasma.PushButton { width: grid.w; height: 60; text: "3"; onClicked: enterDigit("3");}
                      Plasma.PushButton { width: grid.w; height: 60; text: "*"; onClicked: enterDigit("*");}
                      Plasma.PushButton { width: grid.w; height: 60; text: "0"; onClicked: enterDigit("0");}
                      Plasma.PushButton { width: grid.w; height: 60; text: "#"; onClicked: enterDigit("#");}
                      Plasma.PushButton { width: grid.w; height: 60; text: "Del"; onClicked: deleteLastDigit();}
                      Item { width: grid.w; height:60}
                      Plasma.PushButton { width: grid.w; height: 60; text: "Call"; onClicked: call();}
                  }
              }
              Rectangle {
                id : display
                width : main.width;
                height : 35
                color : "white"
                Text {
                    id : number;
                    anchors.fill : parent;
                    text : "Please type a number"
                }
              }
    }
}
