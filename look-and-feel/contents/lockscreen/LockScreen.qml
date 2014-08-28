import QtQuick 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import "../components"

Leaves {
    id: lockscreen
    signal tryUnlock(string code)

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

        property string code

        function lockKeyPressed(id) {
            hideTimer.stop();
            code += id;
        }

        function lockKeyReleased(id) {
            hideTimer.start();
            code += id;
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
                if (stripe.opacity < 1) {
                    stripe.opacity = 1;
                    return;
                }

                stripe.lockKeyPressed(stripe.childAt(mouseX, mouseY).value);
            }

            onReleased: {
                if (stripe.opacity < 1) {
                    return;
                }

                stripe.lockKeyReleased(stripe.childAt(mouseX, mouseY).value);
            }
        }

        Timer {
            id: hideTimer
            interval: 1000
            running: parent.opacity == 1
            onTriggered: {
                stripe.opacity = 0;
//                 console.log("CODE SO FAR: " + stripe.code);
                lockscreen.tryUnlock(stripe.code);
                stripe.code = '';
            }
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
        color: hour.color
        text: "00"
        font.pixelSize: Math.floor((width - (units.largeSpacing)) / 2)
        horizontalAlignment: Qt.AlignCenter
        verticalAlignment: Qt.AlignVCenter
    }

    Text {
        id: emergencyCall

        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        horizontalAlignment: Qt.AlignCenter
        color: minute.color
        text: i18n("Emergency Call")

        MouseArea {
            anchors.fill: parent
            onClicked: { print("FIXME: Launch the dialer service!") }
        }
    }
}
