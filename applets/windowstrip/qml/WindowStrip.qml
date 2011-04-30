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
    width: 600
    height: 240

    property string locked: "T0k4m4k5"
    signal lockedChanged();

    PlasmaCore.DataSource {
            id: tasksSource
            engine: "tasks"
            interval: 30
            onSourceAdded: {
                print("SOURCE added: " + source);
                connectSource(source)
            }
            Component.onCompleted: {
                connectedSources = sources
                //print("----> thumbnailRects is: " + thumbnailRects);
            }
      }
    // connect from C++ to update
    // - position of the windows, relative to window element
    // - actual position of the row
    // -> calculate screen coordinates from these

    Flickable {
        id: windowFlicker
        objectName: "windowFlicker"

        property int minimumInterval: 50;
        property bool blockUpdates: false;
        signal intermediateFrame();

        interactive: true
        contentHeight: windowsRow.height
        contentWidth: windowsRow.width
        anchors.fill: parent

        Timer {
            id: throttleTimer
            running: false
            repeat: false
            interval: 20
            onTriggered: {
                windowFlicker.blockUpdates = false;
            }
        }

        Row {
            // FIX: connect to this row from C++, xChanged()
            id: windowsRow
            objectName: "windowsRow"
            property int mycounter;
            property variant childrenPositions;

            onChildrenChanged: {
                if (windowFlicker.blockUpdates) {
                    //print("skipping");
                    return;
                }
                windowFlicker.blockUpdates = true;
                throttleTimer.start();
                intermediateFrameTimer.start();

                var childrenPositions = Array();
                /*for (var i = 0; i < children.length; i++) {
                    var winId = children[i].winId
                    childrenPositions[winId] = children[i].x
                }*/
                windowsRow.childrenPositions = childrenPositions
            }

            Timer {
                id: intermediateFrameTimer
                running: false
                repeat: false
                interval: 30
                onTriggered: {
                    //print("inserting frame");
                    windowFlicker.intermediateFrame();
                    running = false
                }
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
                    width: 200
                    height: 500
                    property string winId: DataEngineSource

                    Rectangle {
                        opacity: .4
                        anchors.fill: parent
                    }

                    Text {
                        id: windowTitle
                        anchors.bottom: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter;
                        text: "<h2>" + className + "</h2>"
                    }
                }
                Component.onCompleted: {
                    print("done with the item");
                }
            }
        }
    }
}