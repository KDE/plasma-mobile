import Qt 4.6

Item {
    id: homescreen;
    width: 800;
    height: 480;

    Image {
        source: "images/background.png";
        anchors.fill: parent;
    }

    ActivityPanel {
        id: activitypanel;
        anchors.left: homescreen.left;
        anchors.right: homescreen.right;
        y: homescreen.height - 160;
    }

    MouseRegion {
        anchors.left: homescreen.left;
        anchors.right: homescreen.right;
        anchors.bottom: homescreen.bottom;
        height: 160;

        onClicked: {
            activitypanel.state = (activitypanel.state == 'hidden' ? 'show' : 'hidden');
        }
    }

}
