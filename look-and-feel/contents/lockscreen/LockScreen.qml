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

    SatelliteStripe {
        id: stripe
        opacity: 0

        function lockKeyPressed(id) {
            hideTimer.restart();
            console.log(id);
        }

        function lockKeyReleased(id) {
            hideTimer.restart();
            console.log(id);
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 500
                easing.type: Easing.InOutQuad
            }
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
            elementId: "square"
        }

        LockKey {
            id: circle
            value: 2
            anchors.top: parent.top
            anchors.left: square.right

            elementId: "circle"
        }

        LockKey {
            id: ex
            value: 3
            anchors.top: parent.top
            anchors.left: circle.right

            elementId: "ex"

        }

        LockKey {
            id: triangle
            value: 4
            anchors.top: parent.top
            anchors.left: ex.right

            elementId: "triangle"
        }
    }
}
