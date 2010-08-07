/***************************************************************************
 *   Copyright 2010 Marco Martin <mart@kde.org>                            *
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

import Qt 4.7


Image {
    id: dragger;
    objectName: "dragger";
    source: "images/hint.png"
    state: "hidden"

    height: 35
    width: 103
    
    y: parent.height - height;

    property string oldState
    property string location
    property Item targetItem

    onLocationChanged: {
        //dragger.anchors.horizontalCenter = ''
        if (location == "BottomEdge") {
            dragger.source= "images/hint.png"
            dragger.height= 35
            dragger.width= 103
            dragger.anchors.horizontalCenter = homescreen.horizontalCenter;

            dragger.y = homescreen.height - dragger.height;

            draggerRegion.drag.axis = Drag.YAxis
            draggerRegion.drag.minimumY = homescreen.height/2;
            draggerRegion.drag.maximumY = homescreen.height-dragger.height;
        } else if (location == "TopEdge") {
            dragger.source= "images/hint.png"
            dragger.height= 35
            dragger.width= 103
            dragger.anchors.horizontalCenter = homescreen.horizontalCenter;

            dragger.y = 0;

            draggerRegion.drag.axis = Drag.YAxis
            draggerRegion.drag.minimumY = 0;
            draggerRegion.drag.maximumY = homescreen.height/2;
        } else if (location == "LeftEdge") {
            dragger.source= "images/hint-vertical.png"
            dragger.height= 103
            dragger.width= 35
            dragger.anchors.verticalCenter = homescreen.verticalCenter;

            dragger.x = 0;

            draggerRegion.drag.axis = Drag.XAxis
            draggerRegion.drag.minimumX = 0;
            draggerRegion.drag.maximumX = homescreen.width/2;
        //RightEdge
        } else {
            dragger.source= "images/hint-vertical.png"
            dragger.height= 103
            dragger.width= 35
            dragger.anchors.verticalCenter = homescreen.verticalCenter;

            dragger.x = homescreen.width - dragger.width;

            draggerRegion.drag.axis = Drag.XAxis
            draggerRegion.drag.minimumX = homescreen.width/2;
            draggerRegion.drag.maximumX = homescreen.width-dragger.width;
        } 
    }

    MouseArea {
        id: draggerRegion;

        x: - 32 / 2;
        y: - 32 / 2;
        width: parent.width + 32;
        height: parent.height + 32;

        drag.target: parent;
        drag.axis: Drag.YAxis
        drag.minimumY: homescreen.height/2;
        drag.maximumY: homescreen.height-parent.height;

        onPressed: {
            dragger.oldState = dragger.state
            dragger.state = "dragging"
        }

        onReleased: {
            if (dragger.y < 2*(homescreen.height/3)) {
                if (dragger.oldState == "hidden") {
                    dragger.state = "show"
                } else {
                    dragger.state = "hidden"
                }
            } else {
                dragger.state = dragger.oldState
            }
        }
    }
    
    states: [
        State {
            name: "show";
            PropertyChanges {
                target: dragger;
                y: parent.height - dragger.height;
            }
            PropertyChanges {
                target: targetItem;
                y: dragger.y + dragger.height - targetItem.height;
            }
        },
        State {
            name: "hidden";
            PropertyChanges {
                target: dragger;
                y: parent.height - dragger.height;
            }
            PropertyChanges {
                target: targetItem;
                y: -targetItem.height
            }
        },
        State {
            name: "dragging";
            PropertyChanges {
                target: dragger;
                y: dragger.y;
            }
            PropertyChanges {
                target: targetItem;
                y: if (dragger.oldState == "show")
                        dragger.y + dragger.height - targetItem.height
                    else
                        dragger.y + dragger.height
            }
        }
    ]

    transitions: [
        Transition {
            from: "dragging";
            to: "hidden";
            ParallelAnimation {
                PropertyAnimation {
                    targets: dragger;
                    properties: "y";
                    duration: 400;
                    easing.type: "InOutCubic";
                }
                PropertyAnimation {
                    targets: targetItem;
                    properties: "y";
                    duration: 400;
                    easing.type: "InOutCubic";
                }
            }
        },
        Transition {
            from: "dragging";
            to: "show";
            ParallelAnimation {
                PropertyAnimation {
                    targets: dragger;
                    properties: "y";
                    duration: 400;
                    easing.type: "InOutCubic";
                }
                PropertyAnimation {
                    targets: targetItem;
                    properties: "y";
                    duration: 400;
                    easing.type: "InOutCubic";
                }
            }
        }
    ]
}
