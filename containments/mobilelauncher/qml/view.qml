import MobileLauncher 1.0
import Qt 4.6

GridView {
    cellWidth: 100;
    cellHeight: 100
    anchors.fill: parent
    model: myModel
    delegate: Component {
        Rectangle {
            height: 128
            width: 128
            ResultWidget {
                icon: decoration
                text: display
            }
        }
    }
}
