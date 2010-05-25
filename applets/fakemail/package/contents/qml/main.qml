import Qt 4.7
import Qt.widgets 4.7
import Plasma 0.1 as Plasma

import "components"

QGraphicsWidget {
    id : main

    Item {
        id: mainItem
        anchors.fill: main
        Plasma.TabBar {
            id : mainView
            anchors.fill : mainItem

            MessageList {
                id : messageList
                Plasma.TabBar.tabText : "Page"
            }
            MessageDetails {
                id : messageDetails
            }
            Composer {
                id : composer
            }
        }


        Connections {
            target: messageList
            onItemClicked: {
                mainView.currentIndex = 1
                messageDetails.currentIndex = messageList.currentIndex
            }
            onNewClicked: mainView.currentIndex = 2
        }
    }

}
