import MobileLauncher 1.0
import Qt 4.6

GridView {
    anchors.fill: parent
    model: myModel
    flow: GridView.TopToBottom
    snapMode: GridView.SnapToRow
    cellWidth: width/6
    cellHeight: width/6
    delegate: Component {
        Item {
            id: wrapper
            width: wrapper.GridView.view.cellWidth-40
            height: wrapper.GridView.view.cellWidth-40

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
