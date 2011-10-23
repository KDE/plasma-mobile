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
    width: 100
    height: 360
    objectName: "completionPopup"
    id: mainItem
    state: "expanded"

    PlasmaCore.Theme {
        id: theme
    }

    PlasmaCore.FrameSvgItem {
        id: frame

        anchors.fill: parent
        imagePath: "widgets/frame"
        prefix: "raised"

        Component {
            id: myDelegate
            Item {
                id: delegateContainer
                height: 64
                width: (parent.width - parent.rightMargin * 2)
                //anchors.fill: parent
                //anchors.margins: 20
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
                Column {
                    anchors.left: previewImage.right
                    Text {
                        height: 20
                        id: labelText
                        text: "<strong>" + name + "</strong>"
                        elide: Text.ElideMiddle
                        color: theme.textColor
                        //anchors.left: previewImage.right
                        //anchors.top: parent.top
                        //anchors.bottom: parent.bottom
                    }

                    Text {
                        height: 20
                        id: descriptionText
                        text: url
                        elide: Text.ElideMiddle
                        color: theme.textColor
                        //anchors.left: previewImage.right
                        //anchors.top: labelText.bottom
                        //anchors.bottom: parent.bottom
                    }
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
                    anchors.fill: parent
                    onClicked: {
                        print("URL from completer chosen: " + name + " " + url);
                        urlEntered(url);
                    }
                }

            }
        }

        Component {
            id: listHighlight
            PlasmaCore.FrameSvgItem {
                id: highlightFrame
                imagePath: "widgets/viewitem"
                prefix: "selected+hover"
            }
        }

        Row {
            anchors {
                fill: parent
                leftMargin: frame.margins.left
                rightMargin: frame.margins.right
                topMargin: frame.margins.top
                bottomMargin: frame.margins.bottom
            }
            y: 16

            ListView {
                spacing: 16
                clip: true
                width: (parent.width / 2)
                //orientation: ListView.Vertical

                //anchors.fill: parent
                height: parent.height
                model: historyModel
                delegate: myDelegate
                highlight: listHighlight
                //highlight: Rectangle { color: theme.textColor; opacity: 0.3 }
            }

            ListView {
                spacing: 4
                clip: true
                width: (parent.width / 2)
                height: parent.height
                model: bookmarksModel
                delegate: myDelegate
                highlight: Rectangle { color: theme.textColor; opacity: 0.3 }
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
                scale: 0.8
            }
        }
    ]

    transitions: [
        Transition {
            ParallelAnimation {
                PropertyAnimation {
                    properties: "opacity"
                    duration: 400;
                    easing.type: Easing.InOutElastic;
                    easing.amplitude: 2.0; easing.period: 1.5
                }
                PropertyAnimation {
                    properties: "scale"
                    duration: 250;
                    //from: 0.8
                    //to: 1.0
                    easing.type: Easing.InOutElastic;
                    easing.amplitude: 2.0; easing.period: 1.5
                }
            }
        }
    ]

    
}