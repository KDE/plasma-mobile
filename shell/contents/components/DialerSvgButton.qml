import QtQuick 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

Item {
    width: parent.width / parent.columns
    height: parent.buttonHeight
    property var callback
    property string text
    property string sub
    property alias svg: icon.svg

    PlasmaCore.SvgItem{
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
            if (longHold.visible) {
                addNumber(longHold.text);
            } else {
                addNumber(parent.text);
            }
        }
    }
}
