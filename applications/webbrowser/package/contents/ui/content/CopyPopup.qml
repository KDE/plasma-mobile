/*
*   Copyright 2011 by Sebastian Kügler <sebas@kde.org>
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

import QtQuick 1.1
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.qtextracomponents 0.1
import org.kde.plasma.components 0.1 as PlasmaComponents


PlasmaCore.FrameSvgItem {
    id: linkPopup
    objectName: "linkPopup"
    property int iconSize: 32
    property int space: 12
    property string text

    imagePath: "dialogs/background"
    //width: (iconSize*2) + iconSize
    width: buttonColumn.width + margins.left + margins.right
    height: buttonColumn.height + margins.top + margins.bottom
    //height: iconSize*2
    //width: childrenRect.width
    //height: childrenRect.height
    z: 100000
    state: "collapsed"

    function showPopup(pos)
    {
        linkPopup.x = pos.x
        linkPopup.y = pos.y
        state = "expanded"
    }

    MouseArea {
        id: hidePopup
        //anchors.fill: flickable
        x: -flickable.width; y: -flickable.height; width: flickable.width*2; height: flickable.height*2
        onClicked: linkPopup.state = "collapsed"
        visible: linkPopup.state == "expanded"
        //Rectangle {color: "green"; opacity: 0.2; anchors.fill: parent; }
    }

    //HACK for text copy
    TextInput { id: textField; visible: false }

    Column {
        id: buttonColumn
        x: linkPopup.margins.left
        y: linkPopup.margins.top
        width: button.width
        height: button.height
        PlasmaComponents.ToolButton {
            id: button

            height: theme.hugeIconSize
            iconSource: "edit-copy"
            text: i18n("Copy")
            onClicked:{
                textField.text = linkPopup.text;
                textField.selectAll();
                textField.copy();
                textField.text = ""

                linkPopup.state = "collapsed";

            }
        }
    }
    states: [
        State {
            id: expanded
            name: "expanded";
            PropertyChanges { target: linkPopup; opacity: 1.0; scale: 1.0 }
        },
        State {
            id: collapsed
            name: "collapsed";
            PropertyChanges { target: linkPopup; opacity: 0; scale: 0.9 }
        }
    ]

    transitions: [
        Transition {
            from: "collapsed"; to: "expanded"
            ParallelAnimation {
                ScriptAction {
                    script: flickable.interactiveSuspended = true;
                }
                PropertyAnimation { properties: "opacity"; duration: 175; easing.type: Easing.InExpo; }
                PropertyAnimation { properties: "scale"; duration: 175; easing.type: Easing.InExpo; }
            }
        },
        Transition {
            from: "expanded"; to: "collapsed"
            ParallelAnimation {
                ScriptAction {
                    script: {
                        flickable.interactiveSuspended = false;
                    }
                }
                PropertyAnimation { properties: "opacity"; duration: 175; easing.type: Easing.OutExpo; }
                PropertyAnimation { properties: "scale"; duration: 100; easing.type: Easing.OutExpo; }
            }
        }
    ]
}
