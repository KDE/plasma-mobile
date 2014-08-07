import QtQuick 2.0

Item {
    id: lockscreen

    Leaves {
        id: background
        anchors.fill: parent
    }

    Rectangle {
        id: test
        color: "red"
        height: 100
        width: parent.width
        y: parent.height / 2 - height / 2
        x: 0
    }
}
