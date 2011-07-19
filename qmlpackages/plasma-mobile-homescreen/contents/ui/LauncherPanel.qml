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
    id: launcherPanel;
    height: width>500?128:256;
    state: "show";
    signal flipRequested(bool reverse);
    signal dragOverflow(int degrees)

    function isHomeScreenFlipped()
    {
        return (flipable.state == "Back180" || flipable.state == "Back540");
    }

    Image {
        id: launcherPanelImage;
        anchors.left: parent.left;
        anchors.right: parent.right;
        fillMode: Image.Tile
        source: homeScreenPackage.filePath("images", "launcherpanel.png")
    }

    Image {
        id: stars;
        anchors.left: parent.left;
        anchors.right: parent.right;
        source: homeScreenPackage.filePath("images", "stars.png")
        fillMode: Image.Tile
        y: launcherPanelImage.height - stars.height;
    }

    Rectangle {
        id: launcherPanelbottom;
        objectName: "launcherPanelbottom";

        color: "black";
        anchors.left: parent.left;
        anchors.right: parent.right;
        anchors.top: launcherPanelImage.bottom;
        height: homescreen.height/2;
    }

    Image {
        id: hint;
        source: homeScreenPackage.filePath("images", "hint.png")
        y: -40;
        anchors.horizontalCenter: launcherPanel.horizontalCenter;
    }

    onYChanged : {
        var overflow = Math.max(0, launcherPanel.parent.height - (launcherPanel.y + launcherPanel.height));

        var degrees = 90 / ((launcherPanel.parent.height/2)/overflow);
        launcherPanel.dragOverflow(degrees);
    }

    onWidthChanged : {
        containment.width = width
        height: containment.height
        hintregion.height = hint.height + launcherPanel.height;
    }

    property QGraphicsWidget containment
    onContainmentChanged: {
        containment.parent = launcherPanel
        containment.x = 0
        containment.y = 0
        containment.width = launcherPanel.width
        containment.height = launcherPanel.height
    }

    Image {
        id: activityIndicator
        source: homeScreenPackage.filePath("images", "activityIndicator.png")
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
        target: launcherPanel
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
        height: hint.height + launcherPanel.height;

        drag.target: launcherPanel;
        drag.axis: "YAxis"
        drag.minimumY: launcherPanel.parent.height - launcherPanel.height;
        drag.maximumY: launcherPanel.parent.height;

        property int startY

        onPressed: {
            //ignore the unwanted areas: since mousearea can't have fancy shapes find it there
            if ((mouse.y < hint.height + 35 && parent.state == "show") || (mouse.y < hint.height + 35 && (mouse.x < hint.x - 35 / 2 || mouse.x > hint.x+hint.width + 35 / 2))) {
                mouse.accepted = false;
                return;
            }

            drag.target = launcherPanel;
            launcherPanel.state = "dragging";
            timer.stop();
            startY = launcherPanel.y
            passClicks = true;
        }

        onPositionChanged: {
            if (Math.abs(launcherPanel.y - startY) > 40) {
                passClicks = false;
            }

            if (mouse.y < -100) {
                drag.target = undefined
                rotationDragAnim.to = launcherPanel.parent.height/2 - launcherPanel.height;
                rotationDragAnim.running = true
            }
        }

        onReleased: {
            if (passClicks && hint.opacity == 1) {
                launcherPanel.state = "hidden"
                launcherPanel.state = "show"
                timer.restart();
                return
            }

            var target = launcherPanel.parent.height - (launcherPanel.height / 1.5);
            if (launcherPanel.y < target) {
                launcherPanel.state = "show";
                if (launcherPanel.y < target / 2) {
                    //here don't hide when isHomeScreenFlipped() because we are before the flip
                    if (isHomeScreenFlipped()) {
                        launcherPanel.state = "hidden";
                    }
                    launcherPanel.flipRequested(false);
                }
            } else if (isHomeScreenFlipped()) {
                launcherPanel.state = "show";
            } else {
                launcherPanel.state = "hidden";
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
                launcherPanel.state = "hidden"
            }
        }
    }


    states: [
        State {
            name: "show";
            PropertyChanges {
                target: launcherPanel;
                y: parent.height - height;
            }
            PropertyChanges {
                target: stars;
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
                target: launcherPanel;
                y: parent.height;
            }
            PropertyChanges {
                target: stars;
                opacity: 0;
            }
            PropertyChanges {
                target: containment;
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
                target: launcherPanel;
                x: launcherPanel.x;
                y: launcherPanel.y;

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
                        targets: launcherPanel;
                        properties: "y";
                        duration: 1000;
                        easing.type: "InOutCubic";
                    }
                    PropertyAnimation {
                        targets: stars, containment;
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
                        targets: launcherPanel;
                        properties: "y";
                        duration: 800;
                        easing.type: "InOutCubic";
                    }
                    PropertyAnimation {
                        targets: stars, containment;
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
