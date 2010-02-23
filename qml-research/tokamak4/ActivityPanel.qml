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

    MouseRegion {
        id: hintregion;
        anchors.fill: hint;

        onClicked: {
            activitypanel.state = 'show';
        }
    }

    MouseRegion {
        id: panelregion;

        anchors.left: activitypanel.left;
        anchors.right: activitypanel.right;
        anchors.bottom: activitypanel.bottom;
        height: activitypanel.height;

        onClicked: {
            activitypanel.state = 'hidden';
            console.log("Worked!");
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
                        duration: 1200;
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
                    duration: 400;
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
        }
    ]

}
