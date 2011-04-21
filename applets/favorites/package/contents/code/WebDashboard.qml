import QtQuick 1.0

Item {
    width: 1024
    height: 600

    Column {
        anchors.fill: parent
        
        WebItemList {
            id: bookmarks
            width: parent.width
        }
        WebItemList {
            id: history
            width: parent.width
        }
        WebItemList {
            id: tabs
            width: parent.width
        }
    }
}