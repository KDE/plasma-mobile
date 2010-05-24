import Qt 4.7
import Qt.widgets 4.7
import Plasma 0.1 as Plasma

import "components"

QGraphicsWidget {
    id : main

    Plasma.TabBar {
        id : mainView
        anchors.fill : main

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
}
