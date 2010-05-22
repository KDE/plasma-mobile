import Qt 4.7
import Qt.widgets 4.7
import Plasma 0.1 as Plasma

QGraphicsWidget {
    id: root;

    Plasma.Frame {
        id: frame
        anchors.left: parent.left
        anchors.right: parent.right
        frameShadow : "Raised"

        layout: QGraphicsGridLayout {
            id : lay

            LayoutItem {
                QGraphicsGridLayout.row : 0
                QGraphicsGridLayout.column : 0
                QGraphicsGridLayout.columnMinimumWidth : 30
            }

            Plasma.PushButton {
                id: fromButton
                QGraphicsGridLayout.row : 0
                QGraphicsGridLayout.column : 1
                text: "John"
            }

            Plasma.LineEdit {
                minimumSize.height : fromButton.size.height
                QGraphicsGridLayout.row : 0
                QGraphicsGridLayout.column : 2
                QGraphicsGridLayout.columnSpan : 2
                //QGraphicsGridLayout.alignment : QGraphicsGridLayout.Center
                text: "Subject: Proof of concept"
            }



            Plasma.PushButton {
                id: toButton
                QGraphicsGridLayout.row : 1
                QGraphicsGridLayout.column : 1
                text: "To:"
            }
            Plasma.LineEdit {
                minimumSize.height : toButton.size.height
                QGraphicsGridLayout.row : 1
                QGraphicsGridLayout.column : 2
                QGraphicsGridLayout.columnStretchFactor : 3
                text: "foo@example.com"
            }
            Plasma.PushButton {
                QGraphicsGridLayout.row : 1
                QGraphicsGridLayout.column : 3
                text: "Send"
            }
        }
    }


    Plasma.WebView {
        id : text
        anchors.left: parent.left
        anchors.leftMargin: 60
        anchors.right: parent.right
        anchors.top : frame.bottom
        anchors.bottom : parent.bottom
        width : parent.width - 60
        dragToScroll : true
        html: "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.Quisque vel cursus dui. Nulla feugiat orci ut odio vestibulum id luctus sem adipiscing. Sed eu mauris orci, vel euismod turpis. Integer luctus, sem ut cursus faucibus, dui lacus molestie leo, eu fringilla eros est porta enim. Etiam dapibus luctus lectus nec hendrerit. In pulvinar condimentum tellus, quis condimentum elit cursus vitae. Ut a turpis felis. In dignissim, orci vel consectetur pellentesque, ipsum ipsum dignissim libero, in convallis diam turpis et mauris. Nam quis ligula vitae massa imperdiet ultricies. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Nam orci dolor, laoreet in malesuada eget, pharetra eu erat. Integer quis mi id est fringilla tristique eget non massa. Suspendisse malesuada congue tempus. Maecenas eu odio in lorem dignissim consectetur. Duis aliquet feugiat enim vel tristique. Nulla et urna orci. Ut ut turpis arcu. Aenean nisl tellus, feugiat nec auctor eget, ullamcorper sed purus. Ut sit amet congue elit. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nunc eu tortor ac diam pellentesque consequat vitae quis orci. In metus erat, feugiat ut vulputate eu, facilisis ut arcu. Curabitur lacus nisi, porta id vulputate vel, molestie quis nunc. Fusce eu lorem quis metus lacinia convallis id et arcu. Vivamus mattis ornare tortor, a varius erat mattis vitae. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nam in ligula nec lorem ullamcorper convallis in ac purus. Praesent at est orci. Suspendisse malesuada adipiscing eros sed blandit. Nullam urna nisi, venenatis vitae dapibus non, blandit vitae dolor. Curabitur sollicitudin sagittis lobortis. Nullam ut nibh eu quam sodales pulvinar id id felis. Duis eros nibh, ultricies sit amet bibendum in, malesuada a sapien. Donec faucibus faucibus mauris in imperdiet. Morbi blandit sem a turpis venenatis ac fringilla justo ultricies. Nulla ullamcorper, elit ut dignissim aliquet, diam quam rhoncus risus, vel sodales tellus metus nec tellus. Morbi pretium felis vitae enim blandit eget porta tortor eleifend. Aliquam porta facilisis diam vel tincidunt. Suspendisse quis velit suscipit libero pulvinar interdum. Nulla facilisi. Integer dictum aliquam tellus mollis sollicitudin. Praesent in sem sed purus tempor luctus a non leo. Nunc vulputate, risus vitae tempus elementum, justo magna condimentum lacus, a aliquet sem mi eu erat. Praesent porttitor rutrum cursus. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Mauris mi neque, fringilla non sollicitudin ac, pretium vel elit. Phasellus nisl arcu, mollis quis viverra ac, lacinia quis nisl. Morbi tellus justo, vestibulum non imperdiet eu, blandit id erat. Aenean ac nibh sit amet eros volutpat pulvinar. Nam ut sapien adipiscing tellus commodo lobortis. Quisque aliquam augue eget massa porttitor sagittis. Mauris lacinia fringilla lacus a fringilla. Praesent porttitor elit a dolor volutpat congue. In elit nisl, dignissim sit amet tempor in, congue vitae nulla. Sed volutpat erat in arcu molestie malesuada. Vestibulum felis ante, consectetur id aliquet ac, vehicula ac est. Nulla facilisi. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Aenean dictum tellus non eros facilisis vel euismod elit ornare. In vitae augue sed tortor rhoncus ultricies quis a elit. Aliquam ultrices ipsum et leo interdum quis vulputate odio malesuada. Integer rutrum aliquam purus, quis luctus eros volutpat id. Ut sed laoreet urna. Ut gravida lobortis urna, nec aliquet dolor convallis rhoncus. Phasellus gravida purus ac ante consequat pharetra. Proin egestas purus vitae elit porta imperdiet. Vestibulum sit amet purus nisl. Pellentesque ac tortor urna, a convallis elit. Morbi pulvinar dolor ut nulla auctor ullamcorper. Pellentesque in volutpat justo."
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