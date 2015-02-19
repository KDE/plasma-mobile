 
import QtQuick 2.1
import org.kde.kquickcontrolsaddons 2.0

Flickable {
    id: root
    width: 300
    height: 500
    contentWidth: width
    contentHeight: mainColumn.height

    onMovementEnded: {
        if (contentY > root.height * 3) {
            return;
        }
        slideAnim.enabled = true;
        var newCurrent = mainColumn.childAt(10, contentY+root.height/2);
        contentY = newCurrent.y
    }
    Behavior on contentY {
        id: slideAnim
        enabled: false
        SequentialAnimation {
            PropertyAnimation {
                duration: 150
            }
            ScriptAction {
                script: slideAnim.enabled = false;
            }
        }
    }

    Column {
        id: mainColumn
        Card {
            Text {
                anchors.centerIn: parent
                text: "Settings stuff"
                font.pointSize: 20
            }
        }
        Card {
            color: "blue"
            Text {
                anchors.centerIn: parent
                text: "13:37"
                font.pointSize: 40
            }
        }
        Card {
            id: tasksCard
            z: 9
            color: "green"
            height: root.height - 64
            property bool switching: true
            onCurrentChanged: {
                if (!current) {
                    switching = true;
                }
            }
            Item {
                scale: tasksCard.switching ? 0.333 : 1
                anchors.fill: parent
                ListView {
                    orientation: ListView.Horizontal
                    anchors {
                        fill: parent
                        leftMargin: -root.width
                        rightMargin: -root.width
                    }
                    model: 8
                    spacing: 4
                    delegate: Rectangle {
                        width: root.width
                        height: root.height
                        Text {
                            anchors.centerIn: parent
                            text: "App " + (modelData+1)
                            font.pointSize: 40
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: tasksCard.switching = false;
                        }
                    }
                }
                Behavior on scale {
                    PropertyAnimation {
                        duration: 150
                    }
                }
            }
        }
        Card {
            height: appsFlow.height
            Flow {
                id: appsFlow
                anchors.horizontalCenter: parent.horizontalCenter
                width: Math.floor(parent.width/64) * 64
                Repeater {
                    model: 40
                    delegate: Item {
                        width: 64
                        height: 64
                        Rectangle {
                            width: 48
                            height: 48
                            anchors.centerIn: parent
                        }
                    }
                }
            }
        }
    }
}