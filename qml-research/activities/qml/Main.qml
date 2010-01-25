import Qt 4.6

Item {
    id: container

    property var theme: defaultTheme
    property var currentDateTime

    property alias homeScreen: homeScreen
    property alias clipView: container.clip
    property alias screenWidth: container.width
    property alias screenHeight: container.height

    anchors.centerIn: parent

    Timer {
        interval: 1000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: container.currentDateTime = new Date()
    }

    //CustomTheme { id: defaultTheme }
    CustomTheme {
        id: defaultTheme
        gradient1: "#3e3e3e"; gradient2: "#231f20"; listText: "White"; subText: "#969696"
        bevel1: "#6e6e6e"; bevel2: "Black";
        widgetBackground: "images/widget-background-dark.sci"
        widgetHighlight: "#c18532"; background: "#422a13"
    }

    HomeScreen { id: homeScreen; anchors.fill: parent }
    LockScreen { id: lockScreen; }
}
