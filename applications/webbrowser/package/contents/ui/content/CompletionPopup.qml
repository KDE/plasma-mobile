/***************************************************************************
 *                                                                         *
 *   Copyright 2011 Sebastian Kügler <sebas@kde.org>                       *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/

import QtQuick 1.0
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.graphicswidgets 0.1 as PlasmaWidgets
import org.kde.qtextracomponents 0.1

Item {
    id: mainItem
    objectName: "completionPopup"

    signal urlFilterChanged()

    width: 100
    height: 360
    state: "expanded"


    PlasmaCore.Theme {
        id: theme
    }

    PlasmaCore.FrameSvgItem {
        id: frame
        objectName: "frame"

        anchors.fill: parent
        imagePath: "widgets/frame"
        prefix: "raised"

        Component {
            id: myDelegate
            Item {
                id: delegateContainer
                height: 64
                //width: ((parent.width / 2) - parent.rightMargin * 2)
                width: 380
                anchors.topMargin: 8

                QIconItem {
                    id: previewImage
                    width: 48
                    height: 32
                    icon: QIcon(iconName)
                    //anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.rightMargin: 8
                    //image: preview
                }
                Text {
                    height: 20
                    width: 320
                    id: labelText
                    text: "<strong>" + name + "</strong>"
                    elide: Text.ElideMiddle
                    color: theme.textColor
                    anchors.left: previewImage.right
                    anchors.leftMargin: 12
                    //anchors.left: previewImage.right
                    //anchors.top: parent.top
                    anchors.bottom : parent.verticalCenter
                }

                Text {
                    height: 20
                    id: descriptionText
                    text: url
                    opacity: 0.6
                    elide: Text.ElideMiddle
                    color: theme.textColor
                    anchors.left: previewImage.right
                    anchors.leftMargin: 12
                    width: 320
                    //anchors.left: previewImage.right
                    anchors.top: parent.verticalCenter
                    //anchors.bottom: parent.bottom
                }

                QImageItem {
                    id: rightPreview
                    width: 32
                    height: 32
                    //icon: QIcon("view-history")
                    //anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                    image: preview
                }
                MouseArea {
                    anchors.fill: delegateContainer
                    onClicked: {
                        print("URL from completer chosen: " + name + " " + url);
                        urlEntered(url);
                        mainItem.state = "collapsed"
                    }
                }

            }
        }

        Component {
            id: listHighlight

            PlasmaCore.FrameSvgItem {
            visible: false
                //anchors.fill: parent
                opacity: 0
                id: highlightFrame
                imagePath: "widgets/viewitem"
                prefix: "selected+hover"
            }
        }

        Item {
            id: dashboard
            objectName: "dashboard"
            anchors {
                fill: parent
                leftMargin: frame.margins.left * 2
                rightMargin: frame.margins.right * 2
                topMargin: frame.margins.top * 2
                bottomMargin: frame.margins.bottom * 2
            }
            Text {
                id: topLabel
                text: "<h3>placeholder</h3>"
                height: 48
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top

                Connections {
                    target: urlInput
                    onUrlFilterChanged: {
                        var newFilter = urlInput.urlFilter;
                        print(" New Filter: " + newFilter);
                        if (newFilter != "") {
                            print("nonempty");
                            topLabel.text = i18n("Search for <em>" + newFilter + "</em>...");
                        } else {
                            print(" empty");
                            topLabel.text = i18n("Start typing...");
                        }
                    }
                }

            }
            Item {
                id: history
                anchors.left: parent.left
                anchors.right: parent.horizontalCenter
                anchors.top: topLabel.bottom
                anchors.bottom: parent.bottom
                anchors.rightMargin: 12
                Text {
                    id: historyLabel
                    text: i18n("<h2>Recently visited</h2>")
                    anchors {
                        top: parent.top
                        left: parent.left
                    }
                }
                ListView {
                    //spacing: 16
                    id: historyList
                    clip: true
                    anchors.fill: parent
                    anchors.topMargin: historyLabel.height + 8
                    model: historyModel
                    delegate: myDelegate
                    highlight: listHighlight
                    //highlight: Rectangle { color: theme.textColor; opacity: 0.3 }
                }
                /*
                Rectangle {
                    //color: "blue"
                    opacity: 0.2
                    anchors.fill: historyList
                }
                */
            }

            Item {
                id: bookmarks
                anchors.top: topLabel.bottom
                anchors.left: parent.horizontalCenter
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.leftMargin: 12
                Text {
                    id: bookmarksLabel
                    text: i18n("<h2>Bookmarks</h2>")
                }
                ListView {
                    //spacing: 4
                    clip: true
                    anchors.fill: parent
                    anchors.topMargin: bookmarksLabel.height + 8
                    //width: (parent.width / 2)
                    //height: parent.height
                    model: bookmarksModel
                    delegate: myDelegate
                    highlight: listHighlight
                }
            }
        }
    }

    states: [
        State {
            id: expanded
            name: "expanded";
            PropertyChanges {
                target: mainItem
                opacity: 1.0
                scale: 1.0
            }
        },

        State {
            id: collapsed
            name: "collapsed";
            PropertyChanges {
                target: mainItem
                opacity: 0
                scale: 0.9
            }
        }
    ]

    transitions: [
        Transition {
            from: "collapsed"; to: "expanded"
            ParallelAnimation {
                PropertyAnimation {
                    properties: "opacity"
                    duration: 175;
                    easing.type: Easing.InExpo;
                }
                PropertyAnimation {
                    properties: "scale"
                    duration: 175;
                    easing.type: Easing.InExpo;
                }
            }
        },
        Transition {
            from: "expanded"; to: "collapsed"
            ParallelAnimation {
                PropertyAnimation {
                    properties: "opacity"
                    duration: 175;
                    easing.type: Easing.OutExpo;
                }
                PropertyAnimation {
                    properties: "scale"
                    duration: 100;
                    easing.type: Easing.OutExpo;
                }
            }
        }
    ]
}