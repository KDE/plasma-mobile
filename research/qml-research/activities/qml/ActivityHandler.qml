import Qt 4.7

Item {
    id : handler

    width: 120
    height: 120
    z : 0
    //property var positions : Array({ScreenTop : 0, ScreenLeft : 1, ScreenRight : 2, ScreenBottom : 3});
    property int currentPosition : 0;
    property int backgroundOffset : 35;

    state : "Collapsed"

    function dorelease() {
        if (handler.currentPosition == 1 && handler.x > container.width/2) {
            handler.state = "Expanded";
            return;
        }
        if (handler.currentPosition == 2 && handler.x < container.width/2) {
            handler.state = "Expanded";
            return;
        }
        if (handler.currentPosition == 3 && handler.y < container.height/2) {
            handler.state = "Expanded";
            return;
        }
        if (handler.currentPosition == 0 && handler.y > container.height/2) {
            handler.state = "Expanded";
            return;
        }
        handler.state = "Collapsed";
    }

    function doDrag() {
        handler.state = "Dragging";
        mouseRegion.drag.maximumX = maximumX()
        mouseRegion.drag.minimumX = minimumX()
        mouseRegion.drag.maximumY = maximumY()
        mouseRegion.drag.minimumY = minimumY()
    }

    function calculateX()
    {
        switch (handler.currentPosition) {
           case 0 : return container.width / 2 - handler.width / 2 ;
           case 1 : return -backgroundOffset;
           case 2 : return container.width - handler.width + backgroundOffset;
           case 3 : return container.width / 2 - handler.width / 2;
        }
    }

    function calculateY()
    {
        switch (handler.currentPosition) {
           case 0 : return -backgroundOffset;
           case 1 : return container.height / 2 - handler.height / 2;
           case 2 : return container.height / 2 - handler.height / 2;
           case 3 : return container.height - handler.height + backgroundOffset;
        }
    }

    function maximumX() {
         switch (handler.currentPosition) {
            case 0 : return handler.x;
            case 1 : return container.width - handler.width;
            case 2 : return container.width - handler.width + backgroundOffset;
            case 3 : return handler.x;
        }
    }

    function minimumX() {
         switch (handler.currentPosition) {
            case 0 : return handler.x;
            case 1 : return -backgroundOffset;
            case 2 : return 0;
            case 3 : return handler.x;
        }
    }

    function maximumY() {
         switch (handler.currentPosition) {
            case 0 : return container.height - handler.height;
            case 1 : return handler.y;
            case 2 : return handler.y;
            case 3 : return container.height - handler.height + backgroundOffset;
        }
    }

    function minimumY() {
         switch (handler.currentPosition) {
            case 0 : return -backgroundOffset;
            case 1 : return handler.y;
            case 2 : return handler.y;
            case 3 : return 0;
        }
    }

    function expandedX() {
         switch (handler.currentPosition) {
            case 0 : return handler.x;
            case 1 : return container.width;
            case 2 : return -handler.width;
            case 3 : return handler.x;
        }
    }

    function expandedY() {
         switch (handler.currentPosition) {
            case 0 : return container.height;
            case 1 : return handler.y;
            case 2 : return handler.y;
            case 3 : return -handler.height;
        }
    }

    function expandActivity() {
         handler.state = "Dragging";
         handler.state = "Expanded";
    }

    /*Rectangle {
        anchors.fill: parent
        opacity : 0.5
        color : "white"
    }*/

    MouseRegion {
         id : mouseRegion
         anchors.fill: parent
         drag.target: parent;
         drag.axis: "XandYAxis";
         onPressed : doDrag()
         onReleased: dorelease()
         onClicked: expandActivity()
    }

    Item {
        id : background; anchors.fill: parent;
        anchors.leftMargin : main.theme.touchScreenOffsetHorizontal
        anchors.rightMargin : main.theme.touchScreenOffsetHorizontal
        anchors.topMargin : main.theme.touchScreenOffsetVertical
        anchors.bottomMargin : main.theme.touchScreenOffsetVertical
        transformOrigin : Item.Center
        rotation : {
            switch (handler.currentPosition) {
                case 0 : -180;
                case 1 : 90;
                case 2 : -90;
                case 3 : 0;
            }
        }
        BorderImage {
            anchors.fill: parent;
            source: main.theme.widgetBackground
        }
        Image {
            id : arrowLeft
            rotation : -90
            transformOrigin : Item.Center
            source: main.theme.nextButton
            anchors.left: background.left
            anchors.verticalCenter: background.verticalCenter
            height: background.height
            fillMode: Image.PreserveAspectFit ; smooth : true
            width: 25
            anchors.leftMargin: 5;
        }

        Image {
            id : icon
            source: main.theme.activityDocsButton
            anchors.left: arrowLeft.right
            anchors.verticalCenter: background.verticalCenter
            height: background.height
            fillMode: Image.PreserveAspectFit ; smooth : true
            width: 25
        }

        Image {
            source: main.theme.nextButton
            rotation : -90
            transformOrigin : Item.Center
            anchors.left: icon.right
            anchors.verticalCenter: background.verticalCenter
            height: background.height
            fillMode: Image.PreserveAspectFit ; smooth : true
            width: 25
            anchors.rightMargin: 5;
        }
        BorderImage { anchors.fill: parent; source: main.theme.widgetBackgroundShine }

    }

    states: [
             State {
                 name: "Expanded"
                 PropertyChanges { target: handler; x: expandedX() ; y: expandedY() ; z : 1}
                 PropertyChanges { target: container; state : "Scaled"; }
             },
             State {
                 name: "Collapsed"
                 PropertyChanges { target: handler; x: calculateX() ; y: calculateY() ; z : 0 ; }
                 PropertyChanges { target: container; state : "Normal"; }
             },
             State {
                 name: "Dragging"
                 PropertyChanges { target: handler; x: handler.x ; y: handler.y ; z : 1}
            }
         ]

     transitions: Transition {
         from: "Dragging"
         to: "*"
         NumberAnimation { matchProperties: "x,y"; easing: "easeOutQuad"; duration: 400 }
     }
}
