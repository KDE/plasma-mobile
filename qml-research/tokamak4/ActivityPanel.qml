import Qt 4.6

Item {
    id: activitypanel;
    width: 800;
    height: 160;
    state: "show";

    Image {
        id: activityimage;
        source: "images/activitypanel.png";
        anchors.fill: parent;
    }

    Image {
        id: stars;
        source: "images/stars.png";
        y: activityimage.height - stars.height;
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
        }
    ]

    transitions: [
        Transition {
            from: "show";
            to: "hidden";
            ParallelAnimation {
                NumberAnimation {
                    matchTargets: activitypanel;
                    matchProperties: "y";
                    duration: 1200;
                    easing: "InOutCubic";
                }
                PropertyAnimation {
                    matchTargets: stars;
                    matchProperties: "opacity";
                    duration: 800;
                    easing: "OutCubic";
                }
            }
        },
        Transition {
            from: "hidden";
            to: "show";
            ParallelAnimation {
                NumberAnimation {
                    matchTargets: activitypanel;
                    matchProperties: "y";
                    duration: 800;
                    easing: "InOutCubic";
                }
                PropertyAnimation {
                    matchTargets: stars;
                    matchProperties: "opacity";
                    duration: 1200;
                    easing: "InCubic";
                }
            }
        }
    ]

}
