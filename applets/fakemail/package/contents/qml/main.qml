import Qt 4.7
import GraphicsLayouts 4.7
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
            tabBarShown: false

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
            onNewClicked: {
                composer.subjectText = ""
                composer.bodyText = ""
                composer.toText = ""
                mainView.currentIndex = 2
            }
        }

        Connections {
            target: messageDetails
            onBackClicked: mainView.currentIndex = 0

            onReplyClicked: {
                composer.subjectText = messageDetails.subjectText
                composer.bodyText = messageDetails.bodyText
                composer.toText = messageDetails.fromText
                mainView.currentIndex = 2
            }
            onForwardClicked: {
                composer.subjectText = messageDetails.subjectText
                composer.bodyText = messageDetails.bodyText
                composer.toText = messageDetails.fromText
                mainView.currentIndex = 2
            }
        }

        Connections {
            target: composer
            onBackClicked: mainView.currentIndex = 0
            onSendClicked: mainView.currentIndex = 0
        }
    }

}
