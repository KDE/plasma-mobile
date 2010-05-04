import Qt 4.7

Item {

    id : timeWidget

    BorderImage { anchors.fill: parent; source: main.theme.widgetBackground;
        MouseRegion {
             id : mouseRegion
             anchors.fill: parent
             drag.target: timeWidget;
             drag.axis: "XandYAxis";
             drag.maximumX : container.width - timeWidget.width
             drag.minimumX : 0
             drag.maximumY : container.height - timeWidget.height
             drag.minimumY : 0
        }

    }
    DateTimeFormatter {
        id: time;
        dateTime: main.currentDateTime;
        timeFormat: "h:mm'<sup><small> 'ap'</small></sup>'"
    }

    width: 210
    height: 85

    Text {
        text: time.timeText; /*font.family: main.font.name;*/ font.pixelSize: 60; font.bold: true; color: main.theme.listText
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
    }
    BorderImage { anchors.fill: parent; source: main.theme.widgetBackgroundShine }


}
