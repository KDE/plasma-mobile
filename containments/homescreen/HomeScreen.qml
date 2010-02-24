import Qt 4.6

Rectangle {
    id: homescreen;
    width: 800;
    height: 480;
    color:"black"

    Item {
        id: mainSlot;
        objectName: "mainSlot";

        state : "Visible"
        transformOrigin : Item.Center
        //source: "images/background.png";
        //anchors.fill: parent;

        states: [
            State {
                name: "Visible"
                PropertyChanges { target: mainSlot; scale: 1 }
                     PropertyChanges { target: mainSlot; y: 0 }
            },
            State {
                name: "Hidden"
                PropertyChanges { target: mainSlot; scale: 0.9 }
                PropertyChanges { target: mainSlot; y: homescreen.height }
            }
        ]
        transitions: Transition {
            from: "Visible"
            to: "Hidden"
            SequentialAnimation {
                NumberAnimation { properties: "scale"; easing.type: "InQuad"; duration: 150 }
                NumberAnimation { properties: "y"; easing.type: "InQuad"; duration: 400 }
            }
        }
        transitions: Transition {
            from: "Hidden"
            to: "Visible"
            SequentialAnimation {
                NumberAnimation { properties: "y"; easing.type: "InQuad"; duration: 500 }
                NumberAnimation { properties: "scale"; easing.type: "InQuad"; duration: 150 }
            }
        }
    }

    Item {
        id : spareSlot;
        objectName: "spareSlot";

        state : "Hidden"
        width : homescreen.width;
        height : homescreen.height;

        states: [
            State {
                name: "Hidden"
                PropertyChanges {
                    target: spareSlot;
                    scale: 0.9;
                }
                PropertyChanges {
                    target: spareSlot;
                    y: -homescreen.height;
                }
            },
            State {
                name: "Visible"
                PropertyChanges {
                    target: spareSlot;
                    scale: 1;
                }
                PropertyChanges {
                    target: spareSlot;
                    y: 0;
                }
            }
        ]

        transitions: Transition {
            from: "Visible"
            to: "Hidden"
            SequentialAnimation {
                NumberAnimation {
                    properties: "scale";
                    easing.type: "InQuad";
                    duration: 150;
                }
                NumberAnimation {
                    properties: "y";
                    easing.type: "InQuad";
                    duration: 400;
                }
            }
        }
        transitions: Transition {
            from: "Hidden"
            to: "Visible"
            SequentialAnimation {
                NumberAnimation {
                    properties: "y";
                    easing.type: "InQuad";
                    duration: 500;
                }
                NumberAnimation {
                    properties: "scale";
                    easing.type: "InQuad";
                    duration: 150;
                }
            }
        }
    }

    ActivityPanel {
        id: activitypanel;
        objectName: "activitypanel";

        anchors.left: homescreen.left;
        anchors.right: homescreen.right;
        y: homescreen.height - 160;
    }
}
