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
    color: Qt.rgba(0,0,0,0.5)
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

    MouseArea {
        anchors.fill: parent
        onClicked: widgetsExplorer.closeRequested()
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
                target: iconsFrame;
                anchors.bottom: widgetsExplorer.bottom
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
                target: iconsFrame;
                anchors.bottomMargin: infoPanel.height
                anchors.right: widgetsExplorer.right
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


    PlasmaCore.FrameSvgItem {
        id: iconsFrame

        state: "hidden"
        imagePath: "dialogs/background"

        anchors.fill: parent
        anchors.margins: 32

        MobileComponents.IconGrid {
            id: appletsView
            property string currentPlugin

            anchors {
                fill: parent
                leftMargin: parent.margins.left
                topMargin: parent.margins.top
                rightMargin: parent.margins.right
                bottomMargin: parent.margins.bottom
            }

            model: PlasmaCore.SortFilterModel {
                id: appletsFilter
                sourceModel: myModel
            }


            delegate: Component {
                MobileComponents.IconDelegate {
                    icon: decoration
                    text: display.length<22?display:display.slice(0,22)+"..."
                    textColor: theme.textColor
                    onClicked: {
                        currentPlugin = pluginName
                        infoPanel.icon = decoration
                        infoPanel.name = display
                        infoPanel.version = "Version "+version
                        infoPanel.description = description
                        infoPanel.author = "<b>Author:</b> "+author
                        infoPanel.email = "<b>Email:</b> "+email
                        infoPanel.license = "<b>License:</b> "+license

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

            PlasmaWidgets.PushButton {
                id: closeButton
                width: addButton.width
                anchors.bottom: parent.bottom
                anchors.right: parent.right

                text: i18n("Close")
                onClicked : widgetsExplorer.closeRequested()
            }
        }
    }


    InfoPanel {
        id: infoPanel
    }


}
