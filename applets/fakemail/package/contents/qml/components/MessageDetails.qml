import Qt 4.7
import Qt.widgets 4.7
import Plasma 0.1 as Plasma

QGraphicsWidget {
    id: mainWidget
    property int currentIndex: 0

    signal replyClicked
    signal forwardClicked
    signal backClicked

    property string subjectText: ""
    property string bodyText: ""
    property string fromText: ""

    Item {
        id : main
        anchors.fill : mainWidget

        Component {
                id : messageDelegate

                Item {
                    id: content
                    width: mainView.width
                    height: mainView.height


                    Plasma.WebView {
                        id : bodyView
                        width : content.width
                        height: content.height
                        dragToScroll : true
                        html: "<div style=\"border:1px solid #aaa\">Subject:"+subject+"</div>"+body
                    }
                }
            }

        MessagesModel {
            id: model
        }

        Plasma.Frame {
            id: toolBar
            width: main.width
            frameShadow : "Raised"

            layout: QGraphicsLinearLayout {
                Plasma.PushButton {
                    text: "Back"
                    onClicked: {
                        mainWidget.backClicked()
                    }
                }
                Plasma.PushButton {
                    text: "Reply"
                    onClicked: {
                        mainWidget.subjectText = model.get(mainView.currentIndex).subject
                        mainWidget.bodyText = model.get(mainView.currentIndex).body
                        mainWidget.fromText = model.get(mainView.currentIndex).from
                        mainWidget.replyClicked()
                    }
                }
                Plasma.PushButton {
                    text: "Forward"
                    onClicked: {
                        mainWidget.forwardClicked()
                    }
                }
                QGraphicsWidget{}
            }
        }

        ListView {
            id : mainView
            anchors.top : toolBar.bottom
            anchors.bottom: main.bottom
            anchors.left: main.left
            anchors.right: main.right

            /*contentWidth: content.width
            contentHeight: content.height*/
            clip : true
            orientation: ListView.Horizontal
            snapMode: ListView.SnapOneItem

            model: model

            delegate: messageDelegate
            currentIndex: mainWidget.currentIndex

            /*Connections {
                target: messageList
                onItemClicked: mainView.currentIndex = 1
                onNewClicked: mainView.currentIndex = 1
            }*/
        }
    }
}
