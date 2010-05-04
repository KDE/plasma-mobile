/***************************************************************************
 *   Copyright 2010 Alexis Menard <menard@kde.org>                         *
 *   Copyright 2010 Artur Duque de Souza <asouza@kde.org>                  *
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
    height: 160;
    state: "show";

    Image {
        id: activityimage;
        source: "images/activitypanel.png";
    }

    Image {
        id: stars;
        source: "images/stars.png";
        y: activityimage.height - stars.height;
    }

    Image {
        id: hint;
        source: "images/hint.png";
        y: -40;
        anchors.horizontalCenter: activitypanel.horizontalCenter;
    }

    MouseArea {
        id: hintregion;

        x: hint.x - 35 / 2;
        y: hint.y -  35 / 2;
        width: hint.width + 35;
        height: hint.height + 35;

        drag.target: activitypanel;
        drag.axis: "YAxis"
        drag.minimumY: activitypanel.parent.height - activitypanel.height;
        drag.maximumY: activitypanel.parent.height;

        onClicked: {
            activitypanel.state = 'show';
            timer.restart();
        }

        onPressed: {
            activitypanel.state = 'dragging';
            timer.restart();
        }

        onReleased: {
            if (activitypanel.state != 'dragging')
                return;
            var target = activitypanel.parent.height - (activitypanel.height / 1.5);
            if (activitypanel.y < target) {
                activitypanel.state = 'show';
            } else {
                activitypanel.state = 'hidden';
            }
        }
    }

    MouseArea {
        id: panelregion;

        anchors.left: activitypanel.left;
        anchors.right: activitypanel.right;
        anchors.bottom: activityimage.bottom;
        height: activitypanel.height;

        onClicked: {
            activitypanel.state = 'hidden';
        }
    }

    Timer {
        id : timer
        interval: 4000; running: false;
        onTriggered:  { activitypanel.state = 'hidden' }
    }

    ActivityPanelItems {
        objectName: "panelitems";
        id: shortcuts;
        anchors.horizontalCenter: activitypanel.horizontalCenter;
        anchors.bottom: activitypanel.bottom;
    }

    states: [
        State {
            name: "show";
            PropertyChanges {
                target: activitypanel;
                y: parent.height - 160;
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
                opacity: 1;
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
                PropertyAnimation {
                    target: hint;
                    property: "opacity";
                    duration: 600;
                    easing.type: "InCubic";
                }
            }
        },
        Transition {
            from: "hidden";
            to: "show";
            SequentialAnimation {
                PropertyAnimation {
                    targets: hint;
                    properties: "opacity";
                    duration: 600;
                    easing.type: "OutCubic";
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
        }
    ]

}
