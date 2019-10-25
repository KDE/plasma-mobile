import QtQuick 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

Text {
    width: parent.width / parent.columns
    height: parent.buttonHeight
    horizontalAlignment: Qt.AlignHCenter
    verticalAlignment: Qt.AlignVCenter
    color: dialer.textColor
    font.pixelSize: Math.floor((width - (units.largeSpacing)) / 2)
    property alias sub: longHold.text
    property var callback

    MouseArea {
        anchors.fill: parent
        onClicked: {
            if (callback) {
                callback();
            } else {
                addNumber(parent.text);
            }
        }

        onPressAndHold: {
            if (longHold.visible) {
                addNumber(longHold.text);
            } else {
                addNumber(parent.text);
            }
        }
    }

    Text {
        id: longHold
        anchors {
            top: parent.top
            right: parent.right
        }
        height: parent.height
        width: parent.width / 3
        verticalAlignment: Qt.AlignVCenter
        visible: text.length > 0
        opacity: 0.7

        font.pixelSize: parent.pixelSize * .8
        color: parent.color
    }
}
