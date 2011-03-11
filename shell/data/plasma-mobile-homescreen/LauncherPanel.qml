/***************************************************************************
 *   Copyright 2010 Alexis Menard <menard@kde.org>                         *
 *   Copyright 2010 Artur Duque de Souza <asouza@kde.org>                  *
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

Item {
    id: launcherpanel;
    height: shortcuts.height;
    state: "show";
    signal flipRequested(bool reverse);
    signal dragOverflow(int degrees)

    function isHomeScreenFlipped()
    {
        return (flipable.state == "Back180" || flipable.state == "Back540");
    }

    Image {
        id: activityimage;
        anchors.left: parent.left;
        anchors.right: parent.right;
        fillMode: Image.Tile
        source: "images/launcherpanel.png";
    }

    Image {
        id: stars;
        anchors.left: parent.left;
        anchors.right: parent.right;
        source: "images/stars.png";
        fillMode: Image.Tile
        y: activityimage.height - stars.height;
    }

    Rectangle {
        id: launcherpanelbottom;
        objectName: "launcherpanelbottom";

        color: "black";
        anchors.left: parent.left;
        anchors.right: parent.right;
        anchors.top: activityimage.bottom;
        height: homescreen.height/2;
    }

    Image {
        id: hint;
        source: "images/hint.png";
        y: -40;
        anchors.horizontalCenter: launcherpanel.horizontalCenter;
    }

    onYChanged : {
        var overflow = Math.max(0, launcherpanel.parent.height - (launcherpanel.y + launcherpanel.height));

        var degrees = 90 / ((launcherpanel.parent.height/2)/overflow);
        launcherpanel.dragOverflow(degrees);
    }

    onWidthChanged : {
        if (width < 800) {
            shortcuts.state = "compact"
        } else {
            shortcuts.state = "expanded"
        }
        hintregion.height = hint.height + launcherpanel.height;
    }

    ActivityPanelItems {
        objectName: "panelitems";
        id: shortcuts;
        state: "expanded"
        anchors.horizontalCenter: launcherpanel.horizontalCenter;
        anchors.bottom: launcherpanel.bottom;
    }

    Image {
        id: activityIndicator
        source: "images/activityIndicator.png";
        //anchors.bottom: parent.bottom
        y: parent.height
        x: -width
        ParallelAnimation {
            id: indicatorAnimation
            NumberAnimation {
                id: indicatorAnimationX
                target: activityIndicator
                property: "x"
                duration: 300
            }
            NumberAnimation {
                id: indicatorAnimationY
                target: activityIndicator
                property: "y"
                duration: 300
            }
        }

    }

    PropertyAnimation {
        id: rotationDragAnim
        target: launcherpanel
        properties: "y"
        duration: 300
    }

    MouseArea {
        id: hintregion;

        property bool passClicks;
        property Item activeChild;
        x: 0;
        y: hint.y -  35 / 2;
        width: parent.width;
        height: hint.height + launcherpanel.height;

        drag.target: launcherpanel;
        drag.axis: "YAxis"
        drag.minimumY: launcherpanel.parent.height - launcherpanel.height;
        drag.maximumY: launcherpanel.parent.height;

        property int startY

        onPressed: {
            //ignore the unwanted areas: since mousearea can't have fancy shapes find it there
            if ((mouse.y < hint.height + 35 && parent.state == "show") || (mouse.y < hint.height + 35 && (mouse.x < hint.x - 35 / 2 || mouse.x > hint.x+hint.width + 35 / 2))) {
                mouse.accepted = false;
                return;
            }

            drag.target = launcherpanel;
            launcherpanel.state = "dragging";
            timer.stop();
            startY = launcherpanel.y
            passClicks = true;
        }

        onPositionChanged: {
            if (Math.abs(launcherpanel.y - startY) > 40) {
                passClicks = false;
            }

            if (mouse.y < -100) {
                drag.target = undefined
                rotationDragAnim.to = launcherpanel.parent.height/2 - launcherpanel.height;
                rotationDragAnim.running = true
            }
        }

        onReleased: {
            var child = shortcuts.childAt(mouse.x-shortcuts.x, mouse.y + hintregion.y-shortcuts.y);
            if (passClicks && hint.opacity == 1) {
                launcherpanel.state = "hidden"
                launcherpanel.state = "show"
                timer.restart();
                return
            } else if (passClicks && child) {
                if (activeChild == child) {
                    launcherpanel.flipRequested(true);
                } else {
                    child.clicked();
                    activeChild = child;
                    indicatorAnimationX.to = shortcuts.x + activeChild.x + activeChild.width/2 - activityIndicator.width/2
                    indicatorAnimationY.to = activeChild.y + activeChild.height - activityIndicator.height
                    indicatorAnimation.running = true
                }
            }

            var target = launcherpanel.parent.height - (launcherpanel.height / 1.5);
            if (launcherpanel.y < target) {
                launcherpanel.state = "show";
                if (launcherpanel.y < target / 2) {
                    //here don't hide when isHomeScreenFlipped() because we are before the flip
                    if (isHomeScreenFlipped()) {
                        launcherpanel.state = "hidden";
                    }
                    launcherpanel.flipRequested(false);
                }
            } else if (isHomeScreenFlipped()) {
                launcherpanel.state = "show";
            } else {
                launcherpanel.state = "hidden";
            }
            timer.restart();
        }

    }

    Timer {
        id : timer
        interval: 4000;
        running: false;
        onTriggered:  {
            if (!isHomeScreenFlipped()) {
                launcherpanel.state = "hidden"
            }
        }
    }


    states: [
        State {
            name: "show";
            PropertyChanges {
                target: launcherpanel;
                y: parent.height - height;
            }
            PropertyChanges {
                target: stars;
                opacity: 1;
            }
            PropertyChanges {
                target: shortcuts;
                opacity: 1;
            }
            PropertyChanges {
                target: hint;
                opacity: 0;
            }
            PropertyChanges {
                target: timer;
                running: true
            }
        },
        State {
            name: "hidden";
            PropertyChanges {
                target: launcherpanel;
                y: parent.height;
            }
            PropertyChanges {
                target: stars;
                opacity: 0;
            }
            PropertyChanges {
                target: shortcuts;
                opacity: 0;
            }
            PropertyChanges {
                target: hint;
                opacity: 1;
            }
        },
        State {
            name: "dragging"
            PropertyChanges {
                target: launcherpanel;
                x: launcherpanel.x;
                y: launcherpanel.y;

            }
            PropertyChanges {
                target: hint;
                opacity: hint.opacity;
            }
        }
    ]

    transitions: [
        Transition {
            from: "show";
            to: "hidden";
            SequentialAnimation {
                ParallelAnimation {
                    NumberAnimation {
                        targets: launcherpanel;
                        properties: "y";
                        duration: 1000;
                        easing.type: "InOutCubic";
                    }
                    PropertyAnimation {
                        targets: stars, shortcuts;
                        properties: "opacity";
                        duration: 800;
                        easing.type: "OutCubic";
                    }
                }
                ParallelAnimation {
                    PropertyAnimation {
                        target: hint;
                        property: "opacity";
                        duration: 600;
                        easing.type: "InCubic";
                    }
                }
            }
        },
        Transition {
            from: "hidden";
            to: "show";
            SequentialAnimation {
                ParallelAnimation {
                    PropertyAnimation {
                        targets: hint;
                        properties: "opacity";
                        duration: 600;
                        easing.type: "OutCubic";
                    }
                }
                ParallelAnimation {
                    NumberAnimation {
                        targets: launcherpanel;
                        properties: "y";
                        duration: 800;
                        easing.type: "InOutCubic";
                    }
                    PropertyAnimation {
                        targets: stars, shortcuts;
                        properties: "opacity";
                        duration: 1000;
                        easing.type: "InCubic";
                    }
                }
            }
        },
        Transition {
            from: "dragging";
            to: "*";
            NumberAnimation {
                properties: "x,y";
                easing.type: "OutQuad";
                duration: 400;
            }
        },
        Transition {
            from: "*";
            to: "dragging";
            ParallelAnimation {
                PropertyAnimation {
                    targets: hint;
                    properties: "opacity";
                    duration: 600;
                    easing.type: "OutCubic";
                }
            }
        }
    ]

}
