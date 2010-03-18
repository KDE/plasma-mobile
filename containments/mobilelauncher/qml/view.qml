import MobileLauncher 1.0
import Qt 4.6

GridView {
    anchors.fill: parent
    model: myModel
    delegate: Component {
        Item {
            id: wrapper
            //anchors.centerIn: resultwidget
            width: wrapper.GridView.view.cellWidth-1
            height: wrapper.GridView.view.cellWidth-1

            GraphicsObjectContainer {
                id: iconcontainer
                anchors.horizontalCenter: parent.horizontalCenter
                width: resultwidget.width
                height: resultwidget.height
                ResultWidget {
                    /*size: QSizeF{width: 64; height: 64}*/
                    id: resultwidget
                    icon: decoration
                    text: display
                }
            }
            MouseArea {
                id: mousearea
                anchors.fill: parent
            }
        }
    }
}
