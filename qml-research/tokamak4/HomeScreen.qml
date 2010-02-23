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
                      NumberAnimation { properties: "scale"; easing.type: "InQuad"; duration: 300 }
                      NumberAnimation { properties: "y"; easing.type: "InQuad"; duration: 400 }
                  }
              }
    }

    Image {
        id : activity1;
        state : "Hidden"
        transformOrigin : Item.Center
        source: "images/nebula.png";

        states: [
                 State {
                     name: "Hidden"
                     PropertyChanges { target: activity1; scale: 0.9 }
                     PropertyChanges { target: activity1; y: -homescreen.height}
                 },
                 State {
                     name: "Visible"
                     PropertyChanges { target: activity1; scale: 1 }
                     PropertyChanges { target: activity1; y: 0 }
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
                      NumberAnimation { properties: "y"; easing.type: "InQuad"; duration: 700 }
                      NumberAnimation { properties: "scale"; easing.type: "InQuad"; duration: 300 }
                  }
              }
    }

    ActivityPanel {
        id: activitypanel;
        anchors.left: homescreen.left;
        anchors.right: homescreen.right;
        y: homescreen.height - 160;
    }
}
