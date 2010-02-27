import Qt 4.6
import "qml"
Item {
    width : 800 ; height : 480
    id: view; anchors.centerIn: parent; focus: true; rotation: 0
    Main { id: main; clipView: true; screenWidth: 800; screenHeight: 480 ;}
}
