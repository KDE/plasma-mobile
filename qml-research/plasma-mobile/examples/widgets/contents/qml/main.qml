import Qt 4.6
import Plasma 1.0 as Plasma
QGraphicsWidget { id: root
    size.width: 400
    size.height: 400

    Plasma.PushButton {
      id : myButton
      geometry : Qt.rect(50, 100, 150, 150);
      text : "I am a plasma pusbutton"
    }

}
