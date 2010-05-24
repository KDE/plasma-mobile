import Qt 4.7
import Qt.widgets 4.7
import Plasma 0.1 as Plasma

import "components"

QGraphicsWidget {
    id : main

    

    ListView {
        id : mainView
        anchors.fill : main
        contentWidth: content.width
        contentHeight: content.height
        clip : true
        orientation: ListView.Horizontal
        snapMode: ListView.SnapOneItem

        model : VisualItemModel {
            id : content

            MessageList {
                id : messageList
                height : mainView.height
                width : mainView.width
            }

            Composer {
                id : composer
                height : mainView.height
                width : mainView.width
            }
        }

        Connections {
            target: messageList
            onItemClicked: mainView.currentIndex = 1
            onNewClicked: mainView.currentIndex = 1
        }
    }
}
