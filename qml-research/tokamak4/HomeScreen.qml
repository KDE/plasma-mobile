import Qt 4.6

Rectangle {
    id: homescreen;
    width: 800;
    height: 480;
    color:"black"

    Image {
        id : defaultBackground;
        state : "Visible"
        transformOrigin : Item.Center
        source: "images/background.png";
        //anchors.fill: parent;

        states: [
                 State {
                     name: "Hidden"
                     PropertyChanges { target: defaultBackground; scale: 0.9 }
                     PropertyChanges { target: defaultBackground; y: homescreen.height }
                 },
                 State {
                     name: "Visible"
                     PropertyChanges { target: defaultBackground; scale: 1 }
                     PropertyChanges { target: defaultBackground; y: 0 }
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

    Flipable {
        id : flip;
        state : "Hidden"
        property int angle: 0;
        width : homescreen.width;
        height : homescreen.height;
        transform: Rotation {
            id: rotation
            origin.x: flip.width / 2;
            origin.y: flip.height / 2;
            axis.x: 0;
            axis.y: 1;
            axis.z: 0;
            angle: flip.angle
        }

        front : Image {
            id : activity1;
            source: "images/nebula.png";
        }
        back: Rectangle {
            width: 800;
            height: 480;
            color: "blue";
        }
        states: [
                 State {
                     name: "Hidden"
                     PropertyChanges { target: flip; scale: 0.9 }
                     PropertyChanges { target: flip; y: -homescreen.height}
                 },
                 State {
                     name: "Visible"
                     PropertyChanges { target: flip; scale: 1 }
                     PropertyChanges { target: flip; y: 0 }
                 },
                State {
                     name: "Back"
                     PropertyChanges {
                         target: flip;
                         angle: 180
                     }
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

        transitions: Transition {
            from: "Visible"
            to:"Back"
            ParallelAnimation {
                NumberAnimation {
                    properties: "angle";
                    duration: 800;
                    easing.type: "Linear";
                }
            }
        }

        transitions: Transition {
            from: "Back"
            to:"Visible"
            ParallelAnimation {
                NumberAnimation {
                    properties: "angle";
                    duration: 800;
                    easing.type: "Linear";
                }
            }
        }

        MouseArea {
            // change between default and 'back' states
            onClicked: flip.state = (flip.state == 'Back' ? 'Visible' : 'Back')
            anchors.fill: parent
        }
    }

    ActivityPanel {
        id: activitypanel;
        anchors.left: homescreen.left;
        anchors.right: homescreen.right;
        y: homescreen.height - 160;
    }
}
