import Qt 4.6
import Plasma 1.0 as Plasma

Plasma.Applet {
    id : applet
    geometry : Qt.rect(10, 10, 300, 300);
    
    Plasma.PushButton {
      id : myButton
      geometry : Qt.rect(50, 100, 150, 150);
      text : "I am a plasma pusbutton"
    }
    MouseRegion {
      id : mouseRegion
      //anchors.fill: parent
      x : 0
      y : 0
      width : 300
      height : 300
      drag.target: applet;
      drag.axis: "XandYAxis";
      drag.maximumX : 800 /*- myButton.width*/
      drag.minimumX : 0
      drag.maximumY : 480 /*- myButton.height*/
      drag.minimumY : 0
  }
}

