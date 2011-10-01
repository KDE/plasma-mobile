/*
 *   Copyright 2011 Sebastian Kügler <sebas@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2 or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Library General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 1.0
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.graphicswidgets 0.1 as PlasmaWidgets
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents

Item {
    id: newBookmarkItem

    property int collapsedWidth: 10
    property int expandedWidth: width
    property string defaultText: "http://";
    height: 96
    width: parent.width/4

    state: "collapsed"

    PlasmaCore.DataSource {
        id: bookmarksEngine
        engine: "org.kde.active.bookmarks"
        interval: 0
    }

    PlasmaCore.FrameSvgItem {
        id: frame
        enabledBorders: "LeftBorder|TopBorder|BottomBorder"
        imagePath: "widgets/background"
        anchors.fill: parent
        width: parent.width + 64
        height: parent.height
    }

    Row {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter

        PlasmaWidgets.LineEdit {
            id: lineEdit
            width: expandedWidth - 96
            text: defaultText
            y: frame.margins.top
            clearButtonShown: true
            anchors.verticalCenter: parent.verticalCenter
        }

        PlasmaWidgets.IconWidget {
            id: newIcon
            icon: QIcon("bookmark-new")

            y: frame.margins.top
            minimumIconSize : "48x48"
            maximumIconSize : "48x48"
            preferredIconSize : "48x48"

            anchors.right: parent.right
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter

            onClicked: {
                print("--> new bookmark clicked!")
                if (newBookmarkItem.state == "expanded") {
                    if (isValidBookmark(lineEdit.text)) {
                        print("==> Add Bookmark: " + lineEdit.text);
                        bookmarksEngine.connectSource("add:" + lineEdit.text);
                    }
                } else {

                }
                newBookmarkItem.state = (newBookmarkItem.state == "expanded") ? "collapsed" : "expanded"
            }
            Component.onCompleted: {
                print("icon done" + icon);
                //icon = "bookmark-new";
                state = "collapsed"
            }

            function isValidBookmark(url) {
                var ok = true;

                // empty?
                if (url == "") ok = false;

                // does it begin with http(s)://?
                if ((url.indexOf("http://") != 0) && 
                            (url.indexOf("https://") != 0)) {
                    ok = false;
                }

                if (url == defaultText) {
                    ok = false;
                }
                //print("valid url? " + url + " " + ok);
                return ok;
            }

        }

        Item {
            width: 20
        }
    }

    states: [
        State {
            id: expanded
            name: "expanded";
            //when: mouseArea.pressed
            PropertyChanges {
                target: lineEdit
                width: expandedWidth - 64
                opacity: 1.0
            }
            PropertyChanges {
                target: frame
                width: expandedWidth
                opacity: 1.0
            }
        },

        State {
            id: collapsed
            name: "collapsed";
            PropertyChanges {
                target: lineEdit
                width: collapsedWidth
                opacity: 0
            }
            PropertyChanges {
                target: frame
                width: collapsedWidth
                opacity: 0
            }
        }
    ]

    transitions: [
        Transition {
            PropertyAnimation {
                properties: "width,opacity"
                duration: 200;
                //easing.type: Easing.InOutElastic;
                easing.type: Easing.OutQuad;
                easing.amplitude: 2.0; easing.period: .2
            }
        }
    ]

}