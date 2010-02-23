import Qt 4.6

Item {
    id: activitypanelitems;

    Row {
        id: shortcuts;
        spacing: 45;

        anchors.horizontalCenter: parent.horizontalCenter;
        anchors.bottom: parent.bottom;

        Item {
            width: internet.width;
            height: internet.height;

            Image {
                id: internet;
                source: "images/internet.png";
            }
            MouseArea {
                anchors.fill: internet;
                onClicked: {
                    console.log("Clicked internet :)");
                }
            }
        }

        Item {
            width: instantmessaging.width;
            height: instantmessaging.height;

            Image {
                id: instantmessaging;
                source: "images/im.png";
            }
            MouseArea {
                anchors.fill: instantmessaging;
                onClicked: {
                    console.log("Clicked im :)");
                }
            }
        }

        Item {
            width: phone.width;
            height: phone.height;

            Image {
                id: phone;
                source: "images/phone.png";
            }
            MouseArea {
                anchors.fill: phone;
                onClicked: {
                    console.log("Clicked phone :)");
                }
            }
        }

        Item {
            width: social.width;
            height: social.height;

            Image {
                id: social;
                source: "images/social.png";
            }
            MouseArea {
                anchors.fill: social;
                onClicked: {
                    defaultBackground.state = "Hidden";
                    activity1.state = "Visible";
                    console.log("Clicked social :)");
                }
            }
        }

        Item {
            width: games.width;
            height: games.height;

            Image {
                id: games;
                source: "images/games.png";
            }
            MouseArea {
                anchors.fill: games;
                onClicked: {
                    console.log("Clicked games :)");
                }
            }
        }
    }
}
