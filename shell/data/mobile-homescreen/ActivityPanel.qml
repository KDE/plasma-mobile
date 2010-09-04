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
    id: activitypanel;
    height: shortcuts.height;
    state: "show";
    signal flipRequested(bool reverse);
    signal dragOverflow(int degrees)

    Image {
        id: activityimage;
        anchors.left: parent.left;
        anchors.right: parent.right;
        fillMode: Image.Tile
        source: "images/activitypanel.png";
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
        id: activitypanelbottom;
        objectName: "activitypanelbottom";

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
        anchors.horizontalCenter: activitypanel.horizontalCenter;
    }

    onYChanged : {
        var overflow = Math.max(0, activitypanel.parent.height - (activitypanel.y + activitypanel.height));

        var degrees = 90 / ((activitypanel.parent.height/2)/overflow);
        activitypanel.dragOverflow(degrees);
    }

    onWidthChanged : {
        if (width < 800) {
            shortcuts.state = "compact"
        } else {
            shortcuts.state = "expanded"
        }
        hintregion.height = hint.height + activitypanel.height;
    }

    ActivityPanelItems {
        objectName: "panelitems";
        id: shortcuts;
        state: "expanded"
        anchors.horizontalCenter: activitypanel.horizontalCenter;
        anchors.bottom: activitypanel.bottom;
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

    MouseArea {
        id: hintregion;

        property bool passClicks;
        property Item activeChild;
        x: 0;
        y: hint.y -  35 / 2;
        width: parent.width;
        height: hint.height + activitypanel.height;

        drag.target: activitypanel;
        drag.axis: "YAxis"
        drag.minimumY: activitypanel.parent.height/2 - activitypanel.height;
        drag.maximumY: activitypanel.parent.height;

        onClicked: {
            activitypanel.state = 'show';
            timer.restart();
        }

        onPressed: {
            //ignore the unwanted areas: since mousearea can't have fancy shapes find it there
            if ((mouse.y < hint.height + 35 && parent.state == "show") || (mouse.y < hint.height + 35 && (mouse.x < hint.x - 35 / 2 || mouse.x > hint.x+hint.width + 35 / 2))) {
                mouse.accepted = false;
                return;
            }

            activitypanel.state = 'dragging';
            timer.stop();
            passClicks = true;
        }

        onPositionChanged : {
            if (Math.abs((activitypanel.y  + activitypanel.height) - activitypanel.parent.height) > 40) {
                passClicks = false;
            }
        }

        onReleased: {
            var child = shortcuts.childAt(mouse.x-shortcuts.x, mouse.y + hintregion.y-shortcuts.y);
            if (passClicks && child) {
                if (activeChild == child) {
                    activitypanel.flipRequested(true);
                } else {
                    child.clicked();
                    activeChild = child;
                    indicatorAnimationX.to = shortcuts.x + activeChild.x + activeChild.width/2 - activityIndicator.width/2
                    indicatorAnimationY.to = activeChild.y + activeChild.height - activityIndicator.height
                    indicatorAnimation.running = true
                }
            }

            if (activitypanel.state != 'dragging') {
                return;
            }
            var target = activitypanel.parent.height - (activitypanel.height / 1.5);
            if (activitypanel.y < target) {
                activitypanel.state = 'show';
                if (activitypanel.y < target / 2) {
                    activitypanel.state = 'hidden';
                    activitypanel.flipRequested(false);
                }
            } else {
                activitypanel.state = 'hidden';
            }
            timer.restart();
        }

    }

    Timer {
        id : timer
        interval: 4000; running: false;
        onTriggered:  { activitypanel.state = 'hidden' }
    }


    states: [
        State {
            name: "show";
            PropertyChanges {
                target: activitypanel;
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
                target: phoneQuick;
                opacity: 0;
            }
            PropertyChanges {
                target: flipButton;
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
                target: activitypanel;
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
                target: activitypanel;
                x: activitypanel.x;
                y: activitypanel.y;

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
                        targets: activitypanel;
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
                        targets: activitypanel;
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
