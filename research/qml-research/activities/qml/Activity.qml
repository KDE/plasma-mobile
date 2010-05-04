import Qt 4.7

Item {
    id : activity
    width: container.width
    height: container.height
    clip : true
    x : 0
    y : 0
    transformOrigin : Item.Center
    property Item handler;
    property int activityId;
    //property var positions : Array({ScreenTop : 0, ScreenLeft : 1, ScreenRight : 2, ScreenBottom : 3});

    function calculateX()
    {
        switch (handler.currentPosition) {
           case 0 : return -activity.handler.x;
           case 1 : return - activity.width;
           case 2 : return activity.handler.width;
           case 3 : return -activity.handler.x;
        }
    }

    function calculateY()
    {
        switch (handler.currentPosition) {
           case 0 : return -activity.height;
           case 1 : return -activity.handler.y;
           case 2 : return -activity.handler.y;
           case 3 : return activity.handler.height;
        }
    }

    BorderImage {
        id : background ;
        anchors.fill: parent;
        width : parent.width;
        height : parent.height;
        source :
            {
                switch (activityId) {
                    case 0 : main.theme.activity0Background;
                    case 1 : main.theme.activity1Background;
                    case 2 : main.theme.activity2Background;
                    case 3 : main.theme.activity3Background;
                }
            }
    }

    /*TimeWidget {x : 350; y: 200;}
    TimeWidget {x : 500; y: 350;}*/
    TimeWidget {x : 550; y: 300;}
    Friends {}

    Image {
        id : closeButton
        source: main.theme.closeButton
        width : 50
        fillMode: Image.PreserveAspectFit ; smooth : true
        x : activity.width - width - 10
        y : 10
    }

    MouseRegion {
        x : closeButton.x - main.theme.touchScreenOffsetHorizontal;
        y : closeButton.y - + main.theme.touchScreenOffsetHorizontal;
        width : closeButton.width + main.theme.touchScreenOffsetVertical;
        height : closeButton.height + main.theme.touchScreenOffsetVertical;
        onClicked: { activity.handler.state = "Dragging" ; activity.handler.state = "Collapsed" }
        /*Rectangle {
            anchors.fill: parent
            opacity : 0.5
            color : "white"
        }*/
    }
}
