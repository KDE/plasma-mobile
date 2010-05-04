import Qt 4.7

Item {
    id : lockScreen
    state : "Show"
    width : container.width
    height : container.height + container.height / 3

    Rectangle {
        anchors.fill: parent
        color : "black"
    }

    DateTimeFormatter {
        id: time;
        dateTime: main.currentDateTime;
        timeFormat: "h:mm"
        dateTimeFormat: "yyyy-MM-d"
    }

    Image {
        id : background
        x : 0
        y : 0
        fillMode: Image.PreserveAspectFit ; smooth : true
        source: main.theme.lockScreenBackground

    }


    Text {
        id : text
        text:  time.dateText + " " + time.timeText;
        /*font.family: main.font.name;*/
        font.pixelSize: 60;
        font.bold: true;
        color: main.theme.listText
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        Image {
            z : 1
            id : slider
            x  : slideBar.x
            y  : slideBar.y - height / 2 + 10
            fillMode: Image.PreserveAspectFit ; smooth : true
            source: main.theme.slider
            state : "Start"

            states: [
                  State {
                      name: "Start"
                      PropertyChanges { target: slider; x : slideBar.x }
                  },
                  State {
                      name: "Sliding"
                      PropertyChanges { target: slider; x : slideBar.x }
                  }
              ]
         transitions: Transition {
                  from: "*"
                  to: "Start"
                  NumberAnimation { matchProperties: "x"; easing: "Linear"; duration: 200 }
              }
        }

        Image {
            id : slideBar
            x  : parent.width / 2 - width /2
            y  : parent.height + height
            fillMode: Image.PreserveAspectFit ; smooth : true
            source: main.theme.sliderBar
        }

        MouseRegion {
             id : mouseRegion
             x : slider.x - main.theme.touchScreenOffsetHorizontal;
             y : slider.y - + main.theme.touchScreenOffsetHorizontal;
             width : slider.width + main.theme.touchScreenOffsetVertical;
             height :slider.height + main.theme.touchScreenOffsetVertical;
             drag.target: slider;
             drag.axis: "XAxis";
             drag.maximumX : slideBar.width + slider.width
             drag.minimumX : slideBar.x
             onPositionChanged : doUnlock(mouse.x)
             onReleased: { slider.state = "Start" }
             onPressed: { slider.state = "Sliding" }

             function doUnlock(x)
             {
                if (slider.x == slideBar.width + slider.width)
                    lockScreen.state = "Hidden"
             }

             /*Rectangle {
                 anchors.fill: parent
                 opacity : 0.5
                 color : "white"
             }*/
        }

    }

    states: [
             State {
                 name: "Hidden"
                 PropertyChanges { target: lockScreen; y : container.height ; }
             },
             State {
                 name: "Show"
                 PropertyChanges { target: lockScreen; y : 0 }
             }
         ]
    transitions: Transition {
             from: "Show"
             to: "Hidden"
             NumberAnimation { matchProperties: "y"; easing: "InBack"; duration: 500 }
         }
}
