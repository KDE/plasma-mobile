import MobileLauncher 1.0
import Qt 4.7

Rectangle {
    color: Qt.rgba(0,0,0,0.4)
    width: 800
    height: 480

    GridView {
        id: appsView
        objectName: "appsView"

        anchors.fill: parent
        anchors.topMargin: 32
        anchors.bottomMargin: 32
        anchors.leftMargin: 4
        anchors.rightMargin: 4

        model: myModel
        flow: GridView.LeftToRight
        snapMode: GridView.SnapToRow
        cellWidth: width/6
        cellHeight: height/4
        clip: true
        signal clicked

        onWidthChanged : {
            if (width > 600) {
                cellWidth = width/6
            } else {
                cellWidth = width/4
            }
        }

        onHeightChanged : {
            if (height > 600) {
                cellHeight = height/6
            } else {
                cellHeight = height/4
            }
        }

        delegate: Component {
            Item {
                id: wrapper
                width: wrapper.GridView.view.cellWidth-40
                height: wrapper.GridView.view.cellWidth-40
                property string urlText: url

                ResultWidget {
                    minimumIconSize : "64x64"
                    maximumIconSize : "64x64"
                    preferredIconSize : "64x64"
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
                        appsView.currentIndex = index
                        appsView.clicked()
                    }
                }
            }
        }
    }
}
