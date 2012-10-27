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
    state: "collapsed"

    MouseArea {
        id: hidePopup
        //anchors.fill: flickable
        x: -flickable.width; y: -flickable.height; width: flickable.width*2; height: flickable.height*2
        onClicked: linkPopup.state = "collapsed"
        visible: linkPopup.state == "expanded"
        //Rectangle {color: "green"; opacity: 0.2; anchors.fill: parent; }
    }

    Item {
        id: buttonRow
        anchors.fill: parent
        anchors.margins: space*2
        QIconItem {
            id: newWindowIcon
            icon: QIcon("window-new")
            width: linkPopup.iconSize
            height: width
            anchors { top: parent.top; left: parent.left; }
            MouseArea {
                anchors.fill: parent;
            }
        }
        PlasmaComponents.Label {
            id: newWindowLabel
            anchors { verticalCenter: newWindowIcon.verticalCenter; left: newWindowIcon.right; right: parent.right; leftMargin: space }
            text: i18n("Open link in new window")
            elide: Text.ElideMiddle
        }
        MouseArea {
            anchors { top: newWindowIcon.top; bottom: newWindowIcon.bottom; left: parent.left; right: parent.right; }
            onClicked: {
                flickable.newWindowRequested(url);
                print("open in new window " + url);
                linkPopup.state = "collapsed"; 
            }
            onPressed: PropertyAnimation {  target: newWindowIcon; properties: "scale";
                                            from: 1.0; to: 0.75;
                                            duration: 175; easing.type: Easing.OutExpo; }
            onReleased: PropertyAnimation { target: newWindowIcon; properties: "scale";
                                            from: 0.75; to: 1.0;
                                            duration: 175; easing.type: Easing.OutExpo; }
        }
        QIconItem {
            id: copyIcon
            icon: QIcon("edit-copy")
            width: linkPopup.iconSize
            height: linkPopup.iconSize
            anchors { top: newWindowIcon.bottom; left: parent.left; topMargin: space; }
            //enabled: textInput.selectedText != ""
//             MouseArea {
//                 anchors.fill: parent;
//             }
            TextInput { id: textField; visible: false }
        }
        PlasmaComponents.Label {
            id: copyLabel
            anchors { verticalCenter: copyIcon.verticalCenter; left: copyIcon.right; right: parent.right; leftMargin: space }
            text: i18n("Copy link to clipboard");
            elide: Text.ElideMiddle
        }
        MouseArea {
            anchors { top: copyIcon.top; bottom: copyIcon.bottom; left: parent.left; right: parent.right; }
            onClicked: {
                textField.text = url;
                textField.selectAll();
                textField.copy();
                textField.text = ""

                linkPopup.state = "collapsed";

            }
            onPressed: PropertyAnimation {  target: copyIcon; properties: "scale";
                                            from: 1.0; to: 0.75;
                                            duration: 175; easing.type: Easing.OutExpo; }
            onReleased: PropertyAnimation { target: copyIcon; properties: "scale";
                                            from: 0.75; to: 1.0;
                                            duration: 175; easing.type: Easing.OutExpo; }
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
                    script: {
                        placePopup();
                        flickable.interactiveSuspended = true;
                    }
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

    function placePopup () {
        // Smart placement of link popup. The popup sits on top horizontally
        // centered on the actived link or item in the webpage, never covering
        // it. If it doesn't fit within the webview, it's moved under or aligned
        // to the edges.

        // Check if we need to shift vertically
        if (linkRect.x < linkPopup.width/2) {
            // hitting the left edge, anchor to left border
            linkPopup.x = 0;
        } else {
            if (webView.width < linkRect.x + linkPopup.width ) {
                // hitting the right edge, anchoring right
                linkPopup.x = webView.width - linkPopup.width
            } else {
                // Not hitting any edge, align horizontally centered with link rect
                linkPopup.x = linkRect.x-(linkPopup.width/2)+linkRect.width/2
            }
        }

        // Check whether we need to reposition horizontally
        if (linkRect.y < linkPopup.height) {
            // move down under linkRect point
            linkPopup.y = linkRect.y + linkRect.height;
        } else {
            // Normally, the popup sits above the link rectangle
            linkPopup.y = linkRect.y - linkPopup.height;
        }
    }
}
