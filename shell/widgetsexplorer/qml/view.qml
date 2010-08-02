
import Qt 4.7
import Plasma 0.1 as Plasma

Rectangle {
    color: Qt.rgba(0,0,0,0.4)

    
    GridView {
        id: appletsView
        objectName: "appletsView"

        width: (parent.width/4)*3
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.topMargin: 32
        anchors.bottomMargin: closeButton.height

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
                        detailsIcon.icon = decoration
                        detailsNameText.text = display
                    }
                }
            }
        }
    }
    Item {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.topMargin: 32
        anchors.bottomMargin: closeButton.height
        anchors.rightMargin: 4

        width: parent.width/4;
        
        Plasma.IconWidget {
            id: detailsIcon
            y: 32
            anchors.horizontalCenter: parent.horizontalCenter
            minimumIconSize : "64x64"
            maximumIconSize : "64x64"
            preferredIconSize : "64x64"
        }

        Text {
            id: detailsNameText

            width: parent.width
            anchors.top: detailsIcon.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize : 20;
            wrapMode : Text.Wrap

            color: "white"
        }
    }

    Plasma.PushButton {
        id: closeButton
        anchors.bottom: parent.bottom
        anchors.right: parent.right

        text: "Close"
        onClicked : appletsView.closeRequested()
    }

    Plasma.PushButton {
        id: addButton
        anchors.bottom: parent.bottom
        anchors.left: parent.left

        text: "Add widget"
        onClicked : appletsView.addAppletRequested()
    }
}
