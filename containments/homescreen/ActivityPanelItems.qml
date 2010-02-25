import Qt 4.6

Row {
    id: shortcuts;
    spacing: 45;

    anchors.horizontalCenter: parent.horizontalCenter;
    anchors.bottom: parent.bottom;

    Item {
        objectName: "2";
        signal clicked;

        width: internet.width;
        height: internet.height;

        Image {
            id: internet;
            source: "images/internet.png";
        }
        MouseArea {
            objectName: "mousearea";
            anchors.fill: internet;
            onClicked: {
                parent.clicked();
                timer.restart();
            }
        }
    }

    Item {
        objectName: "3";
        signal clicked;

        width: instantmessaging.width;
        height: instantmessaging.height;

        Image {
            id: instantmessaging;
            source: "images/im.png";
        }
        MouseArea {
            objectName: "mousearea";
            anchors.fill: instantmessaging;
            onClicked: {
                parent.clicked();
                timer.restart();
            }
        }
    }

    Item {
        objectName: "4";
        signal clicked;

        width: phone.width;
        height: phone.height;

        Image {
            id: phone;
            source: "images/phone.png";
        }
        MouseArea {
            objectName: "mousearea";
            anchors.fill: phone;
            onClicked: {
                parent.clicked();
                timer.restart();
            }
        }
    }

    Item {
        objectName: "5";
        signal clicked;

        width: social.width;
        height: social.height;

        Image {
            id: social;
            source: "images/social.png";
        }
        MouseArea {
            objectName: "mousearea";
            anchors.fill: social;
            onClicked: {
                parent.clicked();
                timer.restart();
            }
        }
    }

    Item {
        objectName: "6";
        signal clicked;

        width: games.width;
        height: games.height;

        Image {
            id: games;
            source: "images/games.png";
        }
        MouseArea {
            objectName: "mousearea";
            anchors.fill: games;
            onClicked: {
                parent.clicked();
                timer.restart();
            }
        }
    }
}
