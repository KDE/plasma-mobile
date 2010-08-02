
import Qt 4.7
import Plasma 0.1 as Plasma

Rectangle {
    color: Qt.rgba(0,0,0,0.4)

    GridView {
        id: appletsView
        objectName: "appletsView"

        anchors.fill: parent
        anchors.topMargin: 32
        anchors.bottomMargin: closeButton.height
        anchors.leftMargin: 4
        anchors.rightMargin: 4

        model: myModel
        flow: GridView.LeftToRight
        snapMode: GridView.SnapToRow
        cellWidth: width/6
        cellHeight: height/4
        clip: true
        signal addAppletRequested
        signal closeRequested

        delegate: Component {
            Item {
                id: wrapper
                width: wrapper.GridView.view.cellWidth-40
                height: wrapper.GridView.view.cellWidth-40
                property string appletPlugin : pluginName

                Plasma.IconWidget {
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
                        appletsView.currentIndex = index
                        appletsView.addAppletRequested()
                    }
                }
            }
        }
    }
    Plasma.PushButton {
        id: closeButton
        anchors.bottom: parent.bottom
        anchors.right: parent.right

        text: "Close"
        onClicked : appletsView.closeRequested()
    }
}
