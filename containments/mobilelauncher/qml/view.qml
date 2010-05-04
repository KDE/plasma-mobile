import MobileLauncher 1.0
import Qt 4.7

GridView {
    id: gridView
    anchors.fill: parent
    model: myModel
    flow: GridView.LeftToRight
    snapMode: GridView.SnapToRow
    cellWidth: width/6
    cellHeight: width/6
    clip: true
    signal clicked

    delegate: Component {
        Item {
            id: wrapper
            width: wrapper.GridView.view.cellWidth-40
            height: wrapper.GridView.view.cellWidth-40
            property var urlText: url

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

                onClicked : {
                    gridView.currentIndex = index
                    gridView.clicked()
                }
            }
        }
    }
}
