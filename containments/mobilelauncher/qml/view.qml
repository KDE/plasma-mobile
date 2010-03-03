import Qt 4.6

ListView {
    width: 100
    height: 100
    anchors.fill: parent
    model: myModel
    delegate: Component {
        Rectangle {
            height: 50
            width: 100
            Column {
                Text { text: display }
                Text { text: description}
            }
            //Image { image: decoration}
        }
    }
}
