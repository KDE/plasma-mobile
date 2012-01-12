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
    property Item linkRect: Item {}
    property int iconSize: 32
    property int space: 12
    property string url

    imagePath: "dialogs/background"
    //width: (iconSize*2) + iconSize
    width: space*30
    height: space*10
    //height: iconSize*2
    //width: childrenRect.width
    //height: childrenRect.height
    z: 100000
    //anchors { top: parent.bottom; right: parent.right; topMargin: -(iconSize/4); }

    // fully dynamic show / hide
    //state: (textInput.activeFocus && (textInput.selectedText != "" || textInput.canPaste)) ? "expanded" : "collapsed";
    // state controlled externally
    state: "collapsed"

    Item {
        id: buttonRow
        //spacing: space
        //anchors { horizontalCenter: parent.horizontalCenter; verticalCenter: parent.verticalCenter; margins: 8; }
        anchors.fill: parent
        anchors.margins: space*2
        //height: linkPopup.iconSize
        QIconItem {
            id: pasteIcon
            icon: QIcon("edit-paste")
            width: linkPopup.iconSize
            height: linkPopup.iconSize
            anchors { top: parent.top; left: parent.left; }
            //enabled: textInput.canPaste
            MouseArea {
                anchors.fill: parent;
                onClicked: { textField.paste(); linkPopup.state = "collapsed"; }
                onPressed: PropertyAnimation {  target: pasteIcon; properties: "scale";
                                                from: 1.0; to: 0.9;
                                                duration: 175; easing.type: Easing.OutExpo; }
                onReleased: PropertyAnimation { target: pasteIcon; properties: "scale";
                                                from: 0.9; to: 1.0;
                                                duration: 175; easing.type: Easing.OutExpo; }
            }
        }
        PlasmaComponents.Label {
            anchors { verticalCenter: pasteIcon.verticalCenter; left: pasteIcon.right; right: parent.right; leftMargin: space }
            text: "Url: " + url
            elide: Text.ElideMiddle
        }
        QIconItem {
            id: copyIcon
            icon: QIcon("edit-copy")
            width: linkPopup.iconSize
            height: linkPopup.iconSize
            anchors { top: pasteIcon.bottom; left: parent.left; topMargin: space; }
            //enabled: textInput.selectedText != ""
            MouseArea {
                anchors.fill: parent;
                onClicked: { textField.copy(); linkPopup.state = "collapsed"; }
                onPressed: PropertyAnimation {  target: copyIcon; properties: "scale";
                                                from: 1.0; to: 0.9;
                                                duration: 175; easing.type: Easing.OutExpo; }
                onReleased: PropertyAnimation { target: copyIcon; properties: "scale";
                                                from: 0.9; to: 1.0;
                                                duration: 175; easing.type: Easing.OutExpo; }
            }
        }
        PlasmaComponents.Label {
            id: copyLabel
            anchors { verticalCenter: copyIcon.verticalCenter; left: copyIcon.right; right: parent.right; leftMargin: space }
            text: i18n("Copy link");
            elide: Text.ElideMiddle
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
                    script: placePopup();
                }
                PropertyAnimation { properties: "opacity"; duration: 175; easing.type: Easing.InExpo; }
                PropertyAnimation { properties: "scale"; duration: 175; easing.type: Easing.InExpo; }
            }
        },
        Transition {
            from: "expanded"; to: "collapsed"
            ParallelAnimation {
                PropertyAnimation { properties: "opacity"; duration: 175; easing.type: Easing.OutExpo; }
                PropertyAnimation { properties: "scale"; duration: 100; easing.type: Easing.OutExpo; }
            }
        }
    ]

    function placePopup () {
        var rootItem = parent;
        while (rootItem.parent) {
            rootItem = rootItem.parent;
        }
        var mouse = linkRect;
        var distanceToTop = webView.mapToItem(rootItem, mouse.x, mouse.y);
        //var distanceToTop = mouse;
        print( "   distanceToTop: " + distanceToTop.x);
        print( " mouse: x: " + mouse.x + " y: " + mouse.y);
        if (distanceToTop.x < linkPopup.width/2) {
            print(" hitting the left edge " + distanceToTop.x);
            //linkPopup.x = mouse.x

        } else {
            linkPopup.x = mouse.x-(linkPopup.width/2)
        }
        if (distanceToTop.y > linkPopup.height + header.height) {
            print(" placing at mouse.y : " + mouse.y + " " + linkPopup.height)
            linkPopup.y = mouse.y - linkPopup.height;
        } else {
            //linkPopup.y = mouse.y-(linkPopup.width/2)
        }
    }

}
