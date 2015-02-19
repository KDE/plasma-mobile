
import QtQuick 2.1

Rectangle {
    id: cardRoot
    color: "red"
    width: root.width
    height: root.height
    property int step: 0
    property bool current: root.contentY == y


} 
