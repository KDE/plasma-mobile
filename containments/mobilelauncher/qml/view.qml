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
            property string urlText: url

            ResultWidget {
                minimumSize.width: wrapper.width
                minimumSize.height: wrapper.height
                id: resultwidget
                icon: decoration
                text: display
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
