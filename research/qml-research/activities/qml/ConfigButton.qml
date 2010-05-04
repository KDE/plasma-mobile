import Qt 4.7

Item {
    id : configButton

    width: 50
    height: 50

    state:"Hidden"

    Timer {
        id : timer
        interval: 3000; running: false;
        onTriggered:  { configButton.state = 'Hidden' }
    }
    BorderImage { anchors.fill: parent; source: main.theme.widgetBackground }

    Image {
        source: main.theme.configButton
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        width: configButton.width / 1.5; height: configButton.height / 1.5; fillMode: Image.PreserveAspectFit ; smooth : true
    }

    BorderImage { anchors.fill: parent; source: main.theme.widgetBackgroundShine }

    opacity: 0

        states: [
        State {
            name: "Hidden"
            PropertyChanges { target: configButton; opacity: 0 }
        },
        State {
            name: "Show"
            PropertyChanges { target: configButton; opacity: 1 ; y : 0 }
            PropertyChanges { target: timer; running: true }
        }]
    transitions: [
             Transition {
                 from: "Hidden"
                 to: "Show"
                 NumberAnimation { matchProperties: "opacity"; duration: 800 ; easing: "easeOutQuad"}
                 NumberAnimation { matchProperties: "y"; duration: 1000; easing: "easeOutElastic"}
             },
             Transition {
                 from: "Show"
                 to: "Hidden"
                 NumberAnimation { matchProperties: "opacity"; duration: 500; }
                 NumberAnimation { matchProperties: "y"; duration: 500; }
             }
         ]
}
