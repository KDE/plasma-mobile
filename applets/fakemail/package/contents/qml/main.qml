import Qt 4.7
import Qt.widgets 4.7
import Plasma 0.1 as Plasma

import "components"

QGraphicsWidget {
    id : main


    Flickable {
        id : mainFlickable
        anchors.fill : main
        contentWidth: content.width
        contentHeight: content.height
        clip : true

        Row {
            id : content

            MessageList {
                id : messageList
                height : mainFlickable.height
                width : mainFlickable.width
            }

            Composer {
                id : composer
                height : mainFlickable.height
                width : mainFlickable.width
            }


        }

    }
}
