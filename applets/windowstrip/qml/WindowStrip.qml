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
        interactive: true
        contentHeight: windowRow.height
        contentWidth: windowRow.width
        anchors.fill: parent

        Row {
            // FIX: connect to this row from C++, xChanged()
            id: windowRow
            objectName: "windowRow"
            property int mycounter;
            property variant childrenPositions

            onChildrenChanged: {
                var childrenPositions = Array();
                for (var i = 0; i < children.length; i++) {
                    print("childx"+children[i].x)
                    childrenPositions[i] = children[i].x
                }
                windowRow.childrenPositions = childrenPositions
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
                    height: 200

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
    /*
    ListView {
        anchors.fill: parent
        orientation: Qt.Horizontal
        spacing: 10

        model: PlasmaCore.DataModel {
            dataSource: tasksSource
        }

        

        delegate: Item {
            id: tasksDelegate
            width: 200
            height: 200

            Rectangle {
                opacity: .4
                anchors.fill: parent
            }

            Text {
                id: windowTitle
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter;

                //horizontalAlignment: Text.AlignHCenter // doesn't work :/
                text: "<h2>" + className + "</h2>"
            }
        }
    }


    Component.onCompleted: {
        print ("done, yo!");
        lockedChanged();
    }
    */
}