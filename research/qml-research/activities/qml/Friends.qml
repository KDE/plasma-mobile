import Qt 4.7

Item {
    id: mainFriends
    x : 25; y : 25
    width: 450; height: 400
    focus: true
    clip: true;
    Keys.onLeftPressed: content.state = ""
    Keys.onRightPressed: content.state = "Rotated"

    BorderImage { anchors.fill: parent; source: main.theme.widgetBackground;
        MouseRegion {
             id : mouseRegion
             anchors.fill: parent
             drag.target: mainFriends;
             drag.axis: "XandYAxis";
             drag.maximumX : container.width - mainFriends.width
             drag.minimumX : 0
             drag.maximumY : container.height - mainFriends.height
             drag.minimumY : 0
        }
    }

    ListModel {
        id: friends
    }

    Item {
        id: content
        width: parent.height; height: parent.width
        clip: true; anchors.centerIn: parent
        transformOrigin: Item.Center;

        ListView {
            id: list
            clip: true;
            model: friends
            anchors.fill: parent
            width: parent.width
            delegate:
            Rectangle {
                width: parent.width; height: 90
                color: "white"
                Image { source: imagePath; x: 5; y: 5 }
                Column {
                    x: 60
                    y: 5; //anchors.verticalCenter: parent.verticalCenter
                    Text {
                        text: name
                        font.pixelSize: 26
                    }
                    Text {
                        text: msgText
                        font.pixelSize: 22
                        color: "#333333"
                    }
                }
            }
        }

        Script { source: "Facebook.js" }
        Item {
            id: view
            anchors.fill: list
            Component.onCompleted: {
                var fb = facebook(view, "9933e2bc397abe5bd5c9de2d0addfa32")
                fb.friends_get(null, function(friendlist) {
                    fb.users_getInfo(friendlist,['name','pic_square','status'], function(info) {
                        for (var f=0; f<info.length; ++f) {
                            friends.append({
                                "imagePath": info[f].pic_square,
                                "name": info[f].name,
                                "msgText": info[f].status ? info[f].status.message : ""
                            });
                        }
                    })
                })
            }
        }

        states: State {
            name: "Rotated"
            PropertyChanges { target: content; rotation: 0; width: parent.width; height: parent.height }
        }

        transitions: Transition {
            NumberAnimation { matchProperties: "rotation,width,height"; duration: 200 }
        }
    }
}
