 
import QtQuick 2.1
import org.kde.kquickcontrolsaddons 2.0

Flickable {
    id: root
    width: 300
    height: 500
    contentWidth: width
    contentHeight: mainColumn.height
    property real cardMargins: 20

    onMovementEnded: {
        if (contentY > root.height * 3) {
            return;
        }
        slideAnim.enabled = true;
        contentY = Math.round(contentY/root.height) * root.height
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
    Behavior on cardMargins {
        PropertyAnimation {
            duration: 500
        }
    }

    Item {
        id: mainColumn
        width: root.width
        height: root.height * cardHolder.children.length
        Item {
            id: cardHolder
            y: root.contentY
            width: root.width
            height: root.height
            Card {
                step: 0
                Text {
                    anchors.centerIn: parent
                    text: "Settings stuff"
                    font.pointSize: 20
                }
            }
            Card {
                step: 1
                color: "blue"
                Text {
                    anchors.centerIn: parent
                    text: "13:37"
                    font.pointSize: 40
                }
            }
            Card {
                step: 2
                id: tasksCard
                color: "green"
                property bool switching: true
                onCurrentChanged: {
                    if (!current) {
                        switching = true;
                    }
                }
                onSwitchingChanged: {
                    if (switching) {
                        root.cardMargins = 20;
                    } else {
                        root.cardMargins = 0;
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
                step: 3
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
}