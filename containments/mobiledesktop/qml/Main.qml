import Qt 4.6
Flipable {
      id : flip;
      property int angle: 0;
      width : 800;
      height : 480;
      state : "Front";
      property var containment;
      transform: Rotation {
          id: rotation
          origin.x: flip.width / 2;
          origin.y: flip.height / 2;
          axis.x: 0;
          axis.y: 1;
          axis.z: 0;
          angle: flip.angle
      }

      /*Image {
        id : activity1;
        source: "images/background.png";
      }*/

      front : containment;
      back: Rectangle {
          width: 800;
          height: 480;
          color: "blue";
      }
      states: [
              State {
                  name: "Back"
                  PropertyChanges {
                      target: flip;
                      angle: 180;
                  }
              },
              State {
                  name: "Front"
                  PropertyChanges {
                      target: flip;
                      angle: 0;
                  }
              }
          ]
      transitions: Transition {
          from: "Front"
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
          to:"Front"
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
          onClicked: flip.state = (flip.state == 'Back' ? 'Front' : 'Back')
          anchors.fill: parent
      }

 }

