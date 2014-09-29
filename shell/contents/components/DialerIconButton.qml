import QtQuick 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

Item {
    width: parent.width / parent.columns
    height: parent.buttonHeight
    property var callback
    property string text
    property string sub
    property alias source: icon.source

    PlasmaCore.IconItem {
        id: icon
        width: units.iconSizes.medium
        height: width
        anchors.centerIn: parent
    }

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
            if (parent.sub.length > 0) {
                addNumber(parent.sub);
            } else {
                addNumber(parent.text);
            }
        }
    }
}
