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
    //source: "images/hint.png"
    state: "hidden"

    height: 35
    width: 103
    
    y: parent.height - height;

    signal transitionFinished;
    signal activated;

    property string oldState
    property string location
    property Item targetItem

    onLocationChanged: {
        //dragger.anchors.horizontalCenter = ''
        if (location == "BottomEdge") {
            dragger.source= homeScreenPackage.filePath("images", "hint.png")
            dragger.height= 35
            dragger.width= 103
            dragger.anchors.horizontalCenter = homeScreen.horizontalCenter;

            dragger.y = homeScreen.height - dragger.height;

            draggerRegion.drag.axis = Drag.YAxis
            draggerRegion.drag.minimumY = 0;
            draggerRegion.drag.maximumY = homeScreen.height-dragger.height;
        } else if (location == "TopEdge") {
            dragger.source= homeScreenPackage.filePath("images", "hint.png")
            dragger.height= 35
            dragger.width= 103
            dragger.anchors.horizontalCenter = homeScreen.horizontalCenter;

            dragger.y = 0;

            draggerRegion.drag.axis = Drag.YAxis
            draggerRegion.drag.minimumY = 0;
            draggerRegion.drag.maximumY = homeScreen.height;
        } else if (location == "LeftEdge") {
            dragger.source= homeScreenPackage.filePath("images", "hint-vertical.png")
            dragger.height= 103
            dragger.width= 35
            dragger.anchors.verticalCenter = homeScreen.verticalCenter;

            dragger.x = 0;

            draggerRegion.drag.axis = Drag.XAxis
            draggerRegion.drag.minimumX = 0;
            draggerRegion.drag.maximumX = homeScreen.width;
        //RightEdge
        } else {
            dragger.source= homeScreenPackage.filePath("images", "hint-vertical.png")
            dragger.height= 103
            dragger.width= 35
            dragger.anchors.verticalCenter = homeScreen.verticalCenter;

            dragger.x = homeScreen.width - dragger.width;

            draggerRegion.drag.axis = Drag.XAxis
            draggerRegion.drag.minimumX = 0;
            draggerRegion.drag.maximumX = homeScreen.width-dragger.width;
        } 
    }
    
    //FIXME: the drag property doesn't get auto updated and notified
    function updateDrag() {
        if (location == "BottomEdge") {
            draggerRegion.drag.axis = Drag.YAxis
            draggerRegion.drag.minimumY = 0;
            draggerRegion.drag.maximumY = homeScreen.height-dragger.height;
        } else if (location == "TopEdge") {
            draggerRegion.drag.axis = Drag.YAxis
            draggerRegion.drag.minimumY = 0;
            draggerRegion.drag.maximumY = homeScreen.height;
        } else if (location == "LeftEdge") {
            draggerRegion.drag.axis = Drag.XAxis
            draggerRegion.drag.minimumX = 0;
            draggerRegion.drag.maximumX = homeScreen.width;
        //RightEdge
        } else {
            draggerRegion.drag.axis = Drag.XAxis
            draggerRegion.drag.minimumX = 0;
            draggerRegion.drag.maximumX = homeScreen.width-dragger.width;
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
        drag.minimumY: homeScreen.height/2;
        drag.maximumY: homeScreen.height-parent.height;

        onPressed: {
            dragger.activated();
            dragger.oldState = dragger.state
            dragger.state = "dragging"
        }

        onReleased: {
            if (dragger.location == "BottomEdge") {
                if (dragger.y < 2*(homeScreen.height/3)) {
                    if (dragger.oldState == "hidden") {
                        dragger.state = "show"
                    } else {
                        dragger.state = "hidden"
                    }
                } else {
                    dragger.state = dragger.oldState
                }
            } else if (dragger.location == "TopEdge") {
                if (dragger.y > (homeScreen.height/3)) {
                    if (dragger.oldState == "hidden") {
                        dragger.state = "show"
                    } else {
                        dragger.state = "hidden"
                    }
                } else {
                    dragger.state = dragger.oldState
                }
            } else if (dragger.location == "LeftEdge") {
                if (dragger.x > (homeScreen.width/3)) {
                    if (dragger.oldState == "hidden") {
                        dragger.state = "show"
                    } else {
                        dragger.state = "hidden"
                    }
                } else {
                    dragger.state = dragger.oldState
                }
            //RightEdge
            } else {
                if (dragger.x < 2*(homeScreen.width/3)) {
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
    }
    
    states: [
        State {
            name: "show";
            PropertyChanges {
                target: dragger;
                y: if (dragger.location == "BottomEdge") {
                       parent.height - dragger.height;
                   } else if (dragger.location == "TopEdge") {
                       0;
                   //Right, LeftEdge
                   } else {
                       dragger.y;
                   }
                x: if (dragger.location == "BottomEdge" || dragger.location == "TopEdge") {
                       dragger.x;
                   } else if (dragger.location == "LeftEdge") {
                       0;
                   //RightEdge
                   } else {
                       parent.width - dragger.width;
                   }
            }
            PropertyChanges {
                target: targetItem;
                y: if (dragger.location == "BottomEdge" || dragger.location == "TopEdge") {
                       0
                   //Left,RightEdge
                   } else {
                       targetItem.y;
                   }
                x: if (dragger.location == "BottomEdge" || dragger.location == "TopEdge") {
                       targetItem.x;
                   //Left, RightEdge
                   } else {
                       0;
                   }
            }
        },
        State {
            name: "hidden";
            PropertyChanges {
                target: dragger;
                y: if (dragger.location == "BottomEdge") {
                       parent.height - dragger.height;
                   } else if (dragger.location == "TopEdge") {
                       0
                   //Left, RightEdge
                   } else {
                       dragger.y
                   }
                x : if (dragger.location == "BottomEdge" || dragger.location == "TopEdge") {
                        dragger.x
                    } else if (dragger.location == "LeftEdge") {
                        0
                    //RightEdge
                    } else {
                        parent.width - dragger.width
                    }
            }
            PropertyChanges {
                target: targetItem;
                y: if (dragger.location == "BottomEdge") {
                       if (dragger.oldState == "show") {
                           -targetItem.height
                       } else {
                           targetItem.height
                       }
                   } else if (dragger.location == "TopEdge") {
                       if (dragger.oldState == "show") {
                           targetItem.height
                       } else {
                           -targetItem.height
                       }
                   //Left, RightEdge
                   } else {
                       targetItem.y
                   }
                x: if (dragger.location == "BottomEdge" || dragger.location == "TopEdge") {
                       targetItem.x
                   } else if (dragger.location == "LeftEdge") {
                       if (dragger.oldState == "show") {
                           targetItem.width
                       } else {
                           -targetItem.width
                       }
                   //RightEdge
                   } else {
                       if (dragger.oldState == "show") {
                           -targetItem.width
                       } else {
                           targetItem.width
                       }
                   }
            }
        },
        State {
            name: "dragging";
            PropertyChanges {
                target: dragger;
                y: dragger.y;
                x: dragger.x;
            }
            PropertyChanges {
                target: targetItem;
                y: if (dragger.location == "BottomEdge") {
                       if (dragger.oldState == "show") {
                           dragger.y + dragger.height - targetItem.height
                       } else {
                           dragger.y + dragger.height
                       }
                   } else if (dragger.location == "TopEdge") {
                       if (dragger.oldState == "show") {
                           dragger.y
                       } else {
                           dragger.y - targetItem.height
                       }
                   //Left/RightEdge
                   } else {
                       targetItem.y
                   }
                x: if (dragger.location == "BottomEdge" || dragger.location == "TopEdge") {
                       targetItem.x
                   } else if (dragger.location == "LeftEdge") {
                       if (dragger.oldState == "show") {
                           dragger.x
                       } else {
                           dragger.x - targetItem.width
                       }
                   //RightEdge
                   } else {
                       if (dragger.oldState == "show") {
                           dragger.x + dragger.width - targetItem.width
                       } else {
                           dragger.x + dragger.width
                       }
                   }
            }
        }
    ]

    transitions: [
        Transition {
            from: "dragging";
            to: "hidden";
            SequentialAnimation {
                ParallelAnimation {
                    PropertyAnimation {
                        targets: dragger;
                        properties: "x,y";
                        duration: 400;
                        easing.type: "InOutCubic";
                    }
                    PropertyAnimation {
                        targets: targetItem;
                        properties: "x,y";
                        duration: 400;
                        easing.type: "InOutCubic";
                    }
                }
                ScriptAction {
                    script: transitionFinished();
                }
            }
        },
        Transition {
            from: "dragging";
            to: "show";
            SequentialAnimation {
                ParallelAnimation {
                    PropertyAnimation {
                        targets: dragger;
                        properties: "x,y";
                        duration: 400;
                        easing.type: "InOutCubic";
                    }
                    PropertyAnimation {
                        targets: targetItem;
                        properties: "x,y";
                        duration: 400;
                        easing.type: "InOutCubic";
                    }
                }
                ScriptAction {
                    script: transitionFinished();
                }
            }
        }
    ]
/*
    Image {
        id: targetShadow
        source: "images/shadow-top.png"
        anchors.left: dragger.target.right
        width: dragger.target.width
        height: 12
        state: "invisible"
        states: [
            State {
                name: "visible";
                PropertyChanges {
                    target: targetShadow;
                    opacity: 1
                }
            },
            State {
                name: "invisible";
                PropertyChanges {
                    target: targetShadow;
                    opacity: 0
                }
            }
        ]
        transitions: [
            Transition {
                from: "visible";
                to: "invisible";

                PropertyAnimation {
                    targets: targetShadow;
                    properties: "opacity";
                    duration: 300;
                    easing.type: "InOutCubic";
                }
            },
            Transition {
                from: "invisible";
                to: "visible";

                PropertyAnimation {
                    targets: targetShadow;
                    properties: "opacity";
                    duration: 300;
                    easing.type: "InOutCubic";
                }
            }
        ]
    }
    */
}
