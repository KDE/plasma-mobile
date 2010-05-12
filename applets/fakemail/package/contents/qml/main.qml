import Qt 4.7
import Qt.widgets 4.7
import Plasma 0.1 as Plasma

QGraphicsWidget {
    id: page;
    layout: QGraphicsLinearLayout {
        orientation: "Vertical"

        QGraphicsWidget {
            layout: QGraphicsLinearLayout {
                Plasma.PushButton {
                    text: "From:"
                }
                Plasma.LineEdit {
                    text: "john@example.com"
                }
            }
        }


        QGraphicsWidget {
            layout: QGraphicsLinearLayout {
                Plasma.PushButton {
                    text: "To:"
                }
                Plasma.LineEdit {
                    text: "foo@example.com"
                }
            }
        }

        LayoutItem {
            Text {
                wrapMode : Text.WrapAnywhere
                text: "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.";
            }
        }
    }
}
