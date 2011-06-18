// -*- coding: iso-8859-1 -*-
/*
 *   Author: Marco Martin <mart@kde.org>
 *   Date: Sun Nov 7 2010, 18:51:24
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2 or
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

Item {
    id: main
    width: 500
    height: 150

    PlasmaCore.DataSource {
        id: tasksSource
        engine: "tasks"
        interval: 0
        onSourceAdded: {
            //print("SOURCE added: " + source);
            connectSource(source)
        }
        Component.onCompleted: {
            connectedSources = sources
        }
    }
    // connect from C++ to update
    // - position of the windows, relative to window element
    // - actual position of the row
    // -> calculate screen coordinates from these

    Flickable {
        id: windowFlicker
        objectName: "windowFlicker"

        interactive: true
        contentWidth: windowsRow.width
        anchors.fill: parent
        property variant childrenPositions

        Row {
            id: windowsRow
            objectName: "windowsRow"
            spacing: 10

            Timer {
                id: positionsTimer
                interval: 300
                repeat: false
                onTriggered: {
                    var childrenPositions = Array();
                    for (var i = 0; i < windowsRow.children.length; i++) {
                        var winId = windowsRow.children[i].winId
                        var properties = new Object()
                        properties.winId = winId
                        //FIXME: why those hardoced numbers?
                        properties.x = windowsRow.children[i].x + 10
                        properties.y = windowsRow.children[i].y + 20
                        properties.width = windowsRow.children[i].width - 20
                        properties.height = windowsRow.children[i].height - 40
                        childrenPositions[i] = properties
                    }
                    windowFlicker.childrenPositions = childrenPositions
                }
            }

            onChildrenChanged: {
                positionsTimer.running = true
            }
            // add here: onChildrenChanged:, iterate over it, build a list of rectangles
            // assign only after list is complete to save updates

            Repeater {

                model: PlasmaCore.DataModel {
                    dataSource: tasksSource
                }

                onChildrenChanged: {
                    print(" someone changed something");
                    for (var ch in children) {
                        print("Child:" + ch.x)
                    }
                }

                Item {
                    id: windowDelegate
                    width: height*1.6
                    height: main.height
                    onHeightChanged: {
                        positionsTimer.running = true
                    }
                    property string winId: DataEngineSource

                    Rectangle {
                        opacity: .4
                        anchors.fill: parent
                    }

                    Text {
                        id: windowTitle
                        anchors.bottom: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter;
                        text: className
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            print(winId)
                            var service = tasksSource.serviceForSource(winId)
                            var operation = service.operationDescription("activate")

                            service.startOperationCall(operation)
                        }
                    }
                }
            }
        }
    }
}

