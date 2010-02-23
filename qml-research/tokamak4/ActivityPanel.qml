import Qt 4.6

Item {
    id: activitypanel;
    width: 800;
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

//    Rectangle {
//        id: debug;
//        anchors.fill: hintregion;
//        color: "red";
//        opacity: 0.5;
//    }

    MouseRegion {
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
        }

        onPressed: {
            activitypanel.state = 'dragging';
        }

        onReleased: {
            var target = activitypanel.parent.height - (activitypanel.height / 1.5);
            if (activitypanel.y < target) {
                activitypanel.state = 'show';
            } else {
                activitypanel.state = 'hidden';
            }
        }
    }

    MouseRegion {
        id: panelregion;

        anchors.left: activitypanel.left;
        anchors.right: activitypanel.right;
        anchors.bottom: activityimage.bottom;
        height: activitypanel.height;

        onClicked: {
            activitypanel.state = 'hidden';
        }
    }

    ActivityPanelItems {
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
        }
    ]

    transitions: [
        Transition {
            from: "show";
            to: "hidden";
            SequentialAnimation {
                ParallelAnimation {
                    NumberAnimation {
                        matchTargets: activitypanel;
                        matchProperties: "y";
                        duration: 1000;
                        easing: "InOutCubic";
                    }
                    PropertyAnimation {
                        matchTargets: stars, shortcuts;
                        matchProperties: "opacity";
                        duration: 800;
                        easing: "OutCubic";
                    }
                }
                PropertyAnimation {
                    matchTargets: hint;
                    matchProperties: "opacity";
                    duration: 200;
                    easing: "InCubic";
                }
            }
        },
        Transition {
            from: "hidden";
            to: "show";
            SequentialAnimation {
                PropertyAnimation {
                    matchTargets: hint;
                    matchProperties: "opacity";
                    duration: 400;
                    easing: "OutCubic";
                }
                ParallelAnimation {
                    NumberAnimation {
                        matchTargets: activitypanel;
                        matchProperties: "y";
                        duration: 800;
                        easing: "InOutCubic";
                    }
                    PropertyAnimation {
                        matchTargets: stars, shortcuts;
                        matchProperties: "opacity";
                        duration: 1000;
                        easing: "InCubic";
                    }
                }
            }
        },
        Transition {
            from: "dragging";
            to: "*";
            NumberAnimation {
                matchProperties: "x,y";
                easing: "easeOutQuad";
                duration: 400;
            }
        }
    ]

}
