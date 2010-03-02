import Qt 4.6

ListView {
    width: 100
    height: 100
    anchors.fill: parent
    model: myModel
    delegate: Component {
        Rectangle {
            height: 25
            width: 100
            color: model.color
            Text { text: name }
        }
    }
}
