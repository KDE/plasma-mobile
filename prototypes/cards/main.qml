 
import QtQuick 2.1
import org.kde.kquickcontrolsaddons 2.0

Rectangle {
    id: root
    width: 300
    height: 500
    property real scrollValue: 0
    property real cardMargins: 20
    property bool scrollingEnabled: true
    Behavior on scrollValue {
        id: scrollAnim
        NumberAnimation {
            duration: 150
        }
    }
    Behavior on cardMargins {
        PropertyAnimation {
            duration: 500
        }
    }

    Text {
        anchors.centerIn: parent
        text: "Settings stuff"
        font.pointSize: 20
    }
    MouseEventListener {
        anchors.fill: parent
        property real oldY: 0
        onPressed: {
            scrollAnim.enabled = false;
            oldY = mouse.y
        }
        onPositionChanged: {
            if (!root.scrollingEnabled) {
                return;
            }
            scrollValue += (mouse.y - oldY)
            oldY = mouse.y
        }
        onReleased: {
            scrollAnim.enabled = true;
            scrollValue = Math.round(scrollValue / root.height) * root.height
        }
        Card {
            step: 0
            color: "red"
            Text {
                anchors.centerIn: parent
                text: "13:37"
                font.pointSize: 40
            }
        }
        Card {
            id: appCard
            step: 1
            color: "green"
            property bool switching: true
            onSwitchingChanged: {
                if (switching) {
                    root.cardMargins = 20
                } else {
                    root.cardMargins = 0
                }
            }
            onCurrentChanged: {
                if (!current) {
                    switching = true;
                }
            }
            
            Item {
                width: parent.width
                height: parent.height
                scale: !appCard.current || appCard.switching ? 0.4 : 1
                y: appCard.switching ? -70 : 0
                Behavior on scale {
                    PropertyAnimation {
                        duration: 150
                    }
                }
                Behavior on y {
                    PropertyAnimation {
                        duration: 150
                    }
                }
                Rectangle {
                    z: 2
                    anchors.top: parent.top
                    width: parent.width
                    height: parent.height
                    Text {
                        anchors.centerIn: parent
                        text: "APP"
                        font.pointSize: 40
                    }
                    
                    
                    MouseArea {
                        anchors.fill: parent
                        onClicked: appCard.switching = false
                    }
                }

            }
            ListView {
                orientation: ListView.Horizontal
                spacing: 4
                anchors {
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }
                height: parent.height/2.5
                model: 4
                delegate: Rectangle {
                    height: parent.height
                    width: height / (root.height/root.width)
                }
            }
        }
        Card {
            id: appsCard
            step: 2
            color: "blue"
            GridView {
                id: grid
                clip: true
                anchors.fill: parent
                model: 50
                onAtYBeginningChanged: {
                    root.scrollingEnabled = atYBeginning || !appsCard.current;
                }
                delegate: Item {
                    width: grid.cellWidth
                    height: grid.cellHeight
                    Rectangle {
                        anchors.centerIn: parent
                        width: 48
                        height: 48
                    }
                }
            }
        }
    }
}