 
import QtQuick 2.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kquickcontrolsaddons 2.0

Rectangle {
    id: root
    width: 300
    height: 500
    property Item currentApp
    state: "switcher"

    Text {
        anchors.centerIn: parent
        text: "Homescreen"
    }

    Flickable {
        id: mainFlickable
        width: root.width * 2 + 5
        height: root.height * 2 + 5
        
        scale: 0.5
        contentWidth: width
        contentHeight: mainContent.height
        Behavior on scale {
            NumberAnimation {
                duration: units.longDuration
                easing.type: Easing.InOutQuad
            }
        }
        onMovingChanged: {
            if (!moving && contentY < root.height * 2) {
                root.state = "dragging";
            }
            if (contentY < root.height) {
                root.state = "homescreen"
            } else {
                root.state = "switcher"
            }
        }

        Item {
            id: mainContent
            width: parent.width
            height: flow.y + flow.height + root.height
            Flow {
                id: flow
                anchors {
                    left: parent.left
                    right: parent.right
                }
                y: root.height*2
                spacing: 5
                Repeater {
                    model: 5
                    delegate: Rectangle {
                        id: appRect
                        color: "red"
                        width: root.width
                        height: root.height
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                root.currentApp = appRect
                                root.state = "app"
                            }
                            Text {
                                anchors.centerIn: parent
                                text: "App " + modelData
                            }
                        }
                    }
                }
            }
        }
    }
    Rectangle {
        z: 99
        color: "blue"
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        height: 50
        MouseArea {
            anchors.fill: parent
            property int oldY
            property real startY
            onClicked: {
                root.state = "switcher"
            }
            onPressed: {
                if (root.state == "app") {
                    root.state = "zooming";
                } else {
                    root.state = "dragging";
                }     
                oldY = mouse.y;
                startY = mouse.y;
            }
            onPositionChanged: {
                if (root.state == "app" || root.state == "zooming") {
                    mainFlickable.scale = (1 - (startY - mouse.y) / root.height);
                } else {
                    mainFlickable.contentY += oldY - mouse.y;
                }
                oldY = mouse.y;
            }
            onReleased: {
                if (root.state == "app" || root.state == "zooming") {
                    if (mainFlickable.scale < 0.7) {
                        root.state = "switcher"
                    } else {
                        root.state = "app"
                    }
                } else {
                    if (mainFlickable.contentY < root.height) {
                        root.state = "homescreen"
                    } else {
                        root.state = "switcher"
                    }
                }
            }
        }
    }
    states: [
        State {
            name: "switcher"
            PropertyChanges {
                target: mainFlickable
                scale: 0.5
                x: -root.width / 2
                y: -root.height / 2
                interactive: true
                contentY: root.height*2 + (root.currentApp ? root.currentApp.y : 0)
                visible: true
            }
        },
        State {
            name: "dragging"
            PropertyChanges {
                target: mainFlickable
                scale: 0.5
                x: -root.width / 2
                y: -root.height / 2
                interactive: true
                contentY: contentY
                visible: true
            }
        },
        State {
            name: "zooming"
            PropertyChanges {
                target: mainFlickable
                scale: scale
                x: (-root.currentApp.x * (mainFlickable.scale/0.5 - 1) ) +  (2 - mainFlickable.scale/0.5) * (-root.width / 2)
                y: (-root.height / 2) * (2 - mainFlickable.scale/0.5)
                interactive: true
                contentY: (root.height*2 + (root.currentApp ? root.currentApp.y : 0)) * (2 - mainFlickable.scale/0.5) + (root.height*2 + root.currentApp.y) * (mainFlickable.scale/0.5 - 1)
                visible: true
            }
        },
        State {
            name: "app"
            PropertyChanges {
                target: mainFlickable
                scale: 1
                x: -root.currentApp.x
                y: 0
                interactive: false
                contentY: root.height*2 + root.currentApp.y
                visible: true
            }
        },
        State {
            name: "homescreen"
            PropertyChanges {
                target: mainFlickable
                scale: 0.5
                x: -root.width / 2
                y: -root.height / 2
                interactive: true
                contentY: 0
                visible: true
            }
        }
    ]
    transitions: [
        Transition {
            to: "dragging"
        },
        Transition {
            to: "zooming"
        },
        Transition {
            SequentialAnimation {
                ScriptAction {
                    script: {
                        if (root.state != "homescreen") {
                            mainFlickable.visible = true;
                        }
                    }
                }
                PropertyAnimation {
                    target: mainFlickable
                    duration: units.longDuration
                    easing.type: Easing.InOutQuad
                    properties: "x,y,scale,contentY"
                }
                ScriptAction {
                    script: {
                        if (root.state == "homescreen") {
                            mainFlickable.visible = false;
                            root.currentApp = null;
                        }
                    }
                }
            }
        }
    ]
}