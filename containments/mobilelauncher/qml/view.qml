import MobileLauncher 1.0
import Qt 4.6

GridView {
    anchors.fill: parent
    model: myModel
    flow: TopToBottom
    cellWidth: 130
    cellHeight: 130
    delegate: Component {
        Item {
            id: wrapper
            width: wrapper.GridView.view.cellWidth-20
            height: wrapper.GridView.view.cellWidth-20

            GraphicsObjectContainer {
                id: iconcontainer
                anchors.fill: parent
                ResultWidget {
                    minimumSize.width: iconcontainer.width
                    minimumSize.height: iconcontainer.height
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
