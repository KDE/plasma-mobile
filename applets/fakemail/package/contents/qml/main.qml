import Qt 4.7
import Qt.widgets 4.7
import Plasma 0.1 as Plasma

QGraphicsWidget {
    id: page;
    layout: QGraphicsLinearLayout {
        orientation: "Vertical"

        Plasma.Frame {
            frameShadow : "Raised"

            layout: QGraphicsGridLayout {
                id : lay

               LayoutItem {
                   QGraphicsGridLayout.row : 0
                   QGraphicsGridLayout.column : 0
                   QGraphicsGridLayout.columnMinimumWidth : 30
               }

                Plasma.PushButton {
                    QGraphicsGridLayout.row : 0
                    QGraphicsGridLayout.column : 1
                    text: "From:"
                }

                Plasma.LineEdit {
                    QGraphicsGridLayout.row : 0
                    QGraphicsGridLayout.column : 2
                    text: "john@example.com"
                }



                Plasma.PushButton {
                    QGraphicsGridLayout.row : 1
                    QGraphicsGridLayout.column : 1
                    text: "To:"
                }
                Plasma.LineEdit {
                    QGraphicsGridLayout.row : 1
                    QGraphicsGridLayout.column : 2
                    text: "foo@example.com"
                }
            }
        }

        LayoutItem {
            id: textContainer
            Flickable {
                anchors.fill : parent
                contentWidth: text.width
                contentHeight: text.height
                Text {
                    id : text
                    anchors.left: parent.left
                    anchors.leftMargin: 30
                    width : textContainer.width - 30
                    wrapMode : Text.WordWrap
                    text: "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.";
                }
            }
        }
    }
    Plasma.PushButton {
        id : buttonA
        anchors.left: parent.left
        anchors.top: parent.bottom
        text: "A"
        rotation : -90
    }
    Plasma.PushButton {
        id : buttonActions
        anchors.left: parent.left
        anchors.bottom: buttonA.top
        anchors.bottomMargin : 25
        text: "Actions"
        rotation : -90
    }
}
