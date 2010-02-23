import Qt 4.6

Flipable {
    id: cardview;
    width: 800;
    height: 480;
    property int angle: 0;

    transform: Rotation {
        id: rotation
        origin.x: cardview.width / 2;
        origin.y: cardview.height / 2;
        axis.x: 0;
        axis.y: 1;
        axis.z: 0;
        angle: cardview.angle
    }

    front: Rectangle {
        width: 800;
        height: 480;
        gradient: Gradient {
            GradientStop {
                position: 0.0;
                color: "black";
            }
            GradientStop {
                position: 0.5;
                color: "white";
            }
            GradientStop {
                position: 1.0;
                color: "black";
            }
        }
    }

    back: Rectangle {
        width: 800;
        height: 480;
        color: "blue";
    }

    states: State {
        name: "back"
        PropertyChanges {
            target: cardview;
            angle: 180
        }
    }

    transitions: Transition {
        NumberAnimation {
            matchProperties: "angle";
            duration: 800;
            easing.type: "OutCubic";
        }
    }

    MouseArea {
        // change between default and 'back' states
        onClicked: cardview.state = (cardview.state == 'back' ? '' : 'back')
        anchors.fill: parent
    }
}
