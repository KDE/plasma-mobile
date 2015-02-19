
import QtQuick 2.1

Rectangle {
    id: cardRoot
    color: "red"
    width: root.width
    height: root.height
    y: Math.max(Math.min((height - root.cardMargins * (parent.children.length - step)), (-root.contentY + height * step)),
        root.cardMargins*step)
    property int step: 0
    property bool current: -root.contentY + cardRoot.height * step == 0

    Image {
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.top
        }
        opacity: (root.cardMargins/20)*0.4
        source: "top-shadow.png"
    }
} 
