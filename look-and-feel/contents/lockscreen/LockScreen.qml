import QtQuick 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import "../components"

Leaves {
    id: lockscreen

    PlasmaCore.Svg {
        id: symbolsSvg
        imagePath:  Qt.resolvedUrl("images/symbols.svgz")
    }

    MouseArea {
        anchors.fill: parent
        onPressed: {
            stripe.opacity = 1;
        }
    }

    PlasmaCore.DataSource {
        id: dataSource
        engine: "time"
        connectedSources: "Local"
        interval: 30000

        onDataChanged: {
            var date = new Date(data["Local"]["DateTime"]);
            hour.text = date.getHours();
            minute.text = date.getMinutes();
        }

        Component.onCompleted: {
            onDataChanged();
        }
    }

    Text {
        id: hour

        onTextChanged: {
            if (text.length < 2) {
                minute.text = "0" + text;
            }
        }

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: stripe.top
        }
        color: "white" // FIXME: base on wallpaper?
        text: "00"
        font.pixelSize: Math.floor((width - (units.largeSpacing)) / 2)
        horizontalAlignment: Qt.AlignCenter
        verticalAlignment: Qt.AlignVCenter
    }

    SatelliteStripe {
        id: stripe
        opacity: 0

        function lockKeyPressed(id) {
            hideTimer.stop();
            console.log(id);
            console.log((width - (units.largeSpacing * 3)) / 2);
        }

        function lockKeyReleased(id) {
            hideTimer.start();
            console.log(id);
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 500
                easing.type: Easing.InOutQuad
            }
        }

        MouseArea {
            anchors.fill: parent
            onPressed: {
                stripe.lockKeyPressed(stripe.childAt(mouseX, mouseY).value);
            }

            onReleased: {
                stripe.lockKeyReleased(stripe.childAt(mouseX, mouseY).value);
            }

//             onPositionChanged: {
//                 hideTimer.restart();
//             }
        }

        Timer {
            id: hideTimer
            interval: 1000
            running: parent.opacity == 1
            onTriggered: parent.opacity = 0
        }

        LockKey {
            id: square
            value: 1
            anchors.left: parent.left
            elementId: "square"
        }

        LockKey {
            id: circle
            value: 2
            anchors.left: square.right

            elementId: "circle"
        }

        LockKey {
            id: ex
            value: 3
            anchors.left: circle.right

            elementId: "ex"

        }

        LockKey {
            id: triangle
            value: 4
            anchors.left: ex.right

            elementId: "triangle"
        }
    }


    Text {
        id: minute

        onTextChanged: {
            if (text.length < 2) {
                minute.text = "0" + text;
            }
        }

        anchors {
            top: stripe.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        color: "white" // FIXME: base on wallpaper?
        text: "00"
        font.pixelSize: Math.floor((width - (units.largeSpacing)) / 2)
        horizontalAlignment: Qt.AlignCenter
        verticalAlignment: Qt.AlignVCenter
    }

}
