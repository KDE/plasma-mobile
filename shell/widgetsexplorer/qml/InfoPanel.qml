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
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents

PlasmaCore.FrameSvgItem {
    id: infoPanel

    state: "hidden"
    imagePath: "dialogs/background"

    property alias icon: detailsIcon.icon
    property alias name: detailsName.text
    property alias version: detailsVersion.text
    property alias description: detailsDescription.text
    property alias author: detailsAuthor.text
    property alias email: detailsEmail.text
    property alias license: detailsLicense.text

    Item {
        id: infoContent
        anchors {
            fill:parent
            leftMargin: parent.margins.left
            topMargin: parent.margins.top
            rightMargin: parent.margins.right
            bottomMargin: parent.margins.bottom
        }
        state: widgetsExplorer.state=="vertical"?"horizontal":"vertical"

        PlasmaWidgets.IconWidget {
            id: detailsIcon
            y: 8
            anchors.horizontalCenter: parent.horizontalCenter
            minimumIconSize : "128x128"
            maximumIconSize : "128x128"
            preferredIconSize : "128x128"
        }


        Flickable {
            id: infoFlickable

            contentWidth: width;
            contentHeight: column.height
            interactive : true
            clip:true
            width: parent.width<parent.height?parent.width:column.width
            height: parent.width<parent.height?parent.height-detailsIcon.height-addButtonParent.height:parent.height

            Column {
                id:column;
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 8
                spacing: 8

                Text {
                    id: detailsName

                    width: parent.width
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize : 30;
                    wrapMode : Text.Wrap

                    color: theme.textColor
                }

                Text {
                    id: detailsVersion

                    width: parent.width
                    anchors.horizontalCenter: parent.horizontalCenter
                    wrapMode : Text.Wrap

                    color: theme.textColor
                }

                Text {
                    id: detailsDescription

                    width: parent.width
                    wrapMode : Text.Wrap

                    color: theme.textColor
                }


                Text {
                    id: detailsAuthor

                    width: parent.width
                    wrapMode : Text.Wrap

                    color: theme.textColor
                }

                Text {
                    id: detailsEmail

                    width: parent.width
                    wrapMode : Text.Wrap

                    color: theme.textColor
                }

                Text {
                    id: detailsLicense

                    width: parent.width
                    wrapMode : Text.Wrap

                    color: theme.textColor
                }
            }
        }


        PlasmaWidgets.PushButton {
            id: addButton
            text: i18n("Add widget")

            onClicked : widgetsExplorer.addAppletRequested(appletsView.currentPlugin)
        }

        states: [
            State {
                name: "vertical"
                PropertyChanges {
                    target: infoFlickable
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: detailsIcon.bottom
                        bottom: addButton.top
                    }
                }
                PropertyChanges {
                    target: addButton
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        bottom: parent.bottom
                    }
                }
            },
            State {
                name: "horizontal"
                PropertyChanges {
                    target: infoFlickable
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: detailsIcon.bottom
                        bottom: addButton.top
                    }
                }
                PropertyChanges {
                    target: addButton
                    anchors {
                        verticalCenter: parent.verticalCenter
                        right: parent.right
                    }
                }
            }
        ]

    }

    states: [
        State {
            name: "shown"
            PropertyChanges {
                target: infoPanel;
                x: 0

                y: if (widgetsExplorer.state == "vertical")
                        infoPanel.parent.height - infoPanel.height
                    else
                        0
            }
            PropertyChanges {
                target: infoPanel;
                scale: 1
            }
            PropertyChanges {
                target: infoPanel;
                visible: true
            }
            PropertyChanges {
                target: appletsView
                anchors.leftMargin: infoPanel.width
            }
        },
        State {
            name: "hidden"
            PropertyChanges {
                target: infoPanel;
                x: 0

                y: if (widgetsExplorer.state == "vertical")
                        infoPanel.parent.height - infoPanel.height
                    else
                        0
            }
            PropertyChanges {
                target: infoPanel;
                scale: 0
            }
            PropertyChanges {
                target: infoPanel;
                visible: false
            }
            PropertyChanges {
                target: appletsView
                anchors.leftMargin: 0
            }
        }
    ]

    transitions: [
        Transition {
            from: "hidden"
            to:"shown"

            NumberAnimation {
                properties: "x,y";
                duration: 300;
                easing.type: "OutQuad";
            }
            NumberAnimation {
                properties: "scale";
                duration: 300;
                easing.type: "OutQuad";
            }
        }
    ]
}
