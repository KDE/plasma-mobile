import Qt 4.6

Rectangle {
    id : mainActivity
    anchors.centerIn: parent
    color : "black"

    Item {
        id : container
        anchors.fill: parent;
        state : "Normal"
        transformOrigin : Item.Center
        //effect : Blur { id : blurEffect ; blurRadius : 0 }
        property int nbActivities : 4;
        property var activities : new Array(nbActivities);

        MouseRegion { anchors.fill: parent; onClicked: { configButton.state = 'Show' } }

        function initDesktop()
        {
            var handler;
            var handlerSrc = "ActivityHandler.qml";
            var activitySrc = "Activity.qml";
            var panel;
            if(handler==null)
                handler = createComponent(handlerSrc);
            if(panel==null)
                panel = createComponent(activitySrc);

            activities = new Array(nbActivities);
            for(var i = 0; i<nbActivities; i++){
                activities[i] = null;
                if(handler.isReady && panel.isReady){
                    //We create handlers
                    var dynamicObject = handler.createObject();
                    if(dynamicObject == null){
                        print("error creating activity");
                        print(handler.errorsString());
                        return false;
                    }
                    dynamicObject.parent = mainActivity;
                    //TODO Read Settings
                    dynamicObject.currentPosition = i;
                    dynamicObject.x = dynamicObject.calculateX();
                    dynamicObject.y = dynamicObject.calculateY();
                    print("Handler created pos (" + dynamicObject.x + "," + dynamicObject.y + ")");

                    //We create the activity panel
                    var dynamicObject2 = panel.createObject();
                    if(dynamicObject2 == null){
                        print("error creating activity panel");
                        print(panel.errorsString());
                        return false;
                    }
                    dynamicObject2.parent = dynamicObject;
                    dynamicObject2.handler = dynamicObject;
                    dynamicObject2.activityId = i;
                    dynamicObject2.calculateX();
                    dynamicObject2.calculateY();
                    activities[index] = dynamicObject2;
                    print("Activity panel created pos (" + dynamicObject2.x + "," + dynamicObject2.y + ")");

                }else{//isError or isLoading
                    print("error loading block component");
                    print(component.errorsString());
                    return false;
                }
            }
            return true;
        }

        function rand (n)
        {
            return (Math.floor(Math.random() * n + 1 ));
        }
        Component.onCompleted: { container.initDesktop(); }

        Image {
            id : wallpaperImage
            anchors.verticalCenter: parent.verticalCenter; anchors.horizontalCenter: parent.horizontalCenter
            source: main.theme.wallpaper
        }

        ConfigButton {
            id : configButton
            x : container.width - 2*configButton.width
            y : -configButton.height
        }

        TimeWidget {x : 50; y: 50;}

        states: [
                 State {
                     name: "Scaled"
                     PropertyChanges { target: container; scale: 0.9 }
                     //PropertyChanges { target: blurEffect; blurRadius: 5 }
                 },
                 State {
                     name: "Normal"
                     PropertyChanges { target: container; scale: 1 }
                     //PropertyChanges { target: blurEffect; blurRadius: 0 }
                 }
             ]
        transitions: Transition {
                 from: "Normal"
                 to: "Scaled"
                 NumberAnimation { matchProperties: "scale"; easing: "easeInQuad"; duration: 150 }
                 //NumberAnimation { matchProperties: "blurRadius"; easing: "easeInQuad"; duration: 150 }
             }
        transitions: Transition {
                  from: "Scaled"
                  to: "Normal"
                  NumberAnimation { matchProperties: "scale"; easing: "easeInQuad"; duration: 300 }
                  //NumberAnimation { matchProperties: "blurRadius"; easing: "easeInQuad"; duration: 300 }
              }
    }
}

