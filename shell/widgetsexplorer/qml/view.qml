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

Rectangle {
    color: Qt.rgba(0,0,0,0.82)
    id: widgetsExplorer
    objectName: "widgetsExplorer"
    state: "horizontal"
    width:800
    height:480

    signal addAppletRequested(string plugin)
    signal closeRequested

    PlasmaCore.Theme {
        id: theme
    }

    states: [
        State {
            name: "horizontal"
            PropertyChanges {
                target: infoPanel;
                x: parent.width
                y: 0
                width: parent.width/4
                height: parent.height
            }
            PropertyChanges {
                target: appletsView;
                anchors.bottom: widgetsExplorer.bottom
            }
            PropertyChanges {
                target: infoContent;
                anchors.bottomMargin: closeButton.height + 16
            }
            PropertyChanges {
                target: detailsIcon
                anchors.horizontalCenter: parent.horizontalCenter
            }
            PropertyChanges {
                target: infoFlickable
                width: parent.width
                height: parent.height - detailsIcon.height - addButton.height
            }
        },
        State {
            name: "vertical"
            PropertyChanges {
                target: infoPanel;
                x: 0
                y: parent.height
                width: parent.width
                height: parent.height/4
            }
            PropertyChanges {
                target: appletsView;
                anchors.bottomMargin: infopanel.height
                anchors.right: widgetsExplorer.right
            }
            PropertyChanges {
                target: infoContent;
                anchors.bottomMargin: 0
            }
            PropertyChanges {
                target: detailsIcon
                anchors.horizontalCenter: undefined
            }
            PropertyChanges {
                target: infoFlickable
                width: parent.width - detailsIcon.width - addButtonParent.width
                height: parent.height
            }
        }
    ]

    onWidthChanged : {
        orientationTimer.running = true
    }

    Timer {
        id: orientationTimer
        running: false
        repeat: false
        interval: 200
        onTriggered: {
            if (width > height) {
                state = "horizontal"
            } else {
                state = "vertical"
                infoPanel.height = 200
            }
        }
    }


    MobileComponents.IconGrid {
        id: appletsView
        property string currentPlugin
        model: PlasmaCore.SortFilterModel {
            id: appletsFilter
            sourceModel: myModel
        }


        delegate: Component {
            MobileComponents.IconDelegate {
                icon: decoration
                text: display
                textColor: theme.textColor
                onClicked: {
                    currentPlugin = pluginName
                    detailsIcon.icon = decoration
                    detailsName.text = display
                    detailsVersion.text = "Version "+version
                    detailsDescription.text = description
                    detailsAuthor.text = "<b>Author:</b> "+author
                    detailsEmail.text = "<b>Email:</b> "+email
                    detailsLicense.text = "<b>License:</b> "+license

                    if (infoPanel.state == "hidden") {
                        var pos = mapToItem(widgetsExplorer, 0, -infoPanel.height/2)
                        infoPanel.x = pos.x
                        infoPanel.y = pos.y
                        infoPanel.state = "shown"
                    }
                }
            }
        }

        onSearchQueryChanged: {
            appletsFilter.filterRegExp = ".*"+searchQuery+".*"
        }


        width: parent.width
        anchors.fill: parent
        anchors.topMargin: 4
        anchors.bottomMargin: closeButton.height
    }


    PlasmaCore.FrameSvgItem {
        id: infoPanel

        state: "hidden"

        imagePath: "widgets/background"

        Flow {
            id: infoContent
            anchors {
                fill:parent
                leftMargin: parent.margins.left
                topMargin: parent.margins.top
                rightMargin: parent.margins.right
                bottomMargin: parent.margins.bottom
            }

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


            Item {
                id: addButtonParent
                width: parent.width
                height: addButton.height
                PlasmaWidgets.PushButton {
                    id: addButton
                    anchors.horizontalCenter: parent.horizontalCenter

                    text: "Add widget"
                    onClicked : widgetsExplorer.addAppletRequested(appletsView.currentPlugin)
                }
            }

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


    PlasmaWidgets.PushButton {
        id: closeButton
        width: addButton.width
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.rightMargin: 4
        anchors.bottomMargin: 4

        text: "Close"
        onClicked : widgetsExplorer.closeRequested()
    }

}
