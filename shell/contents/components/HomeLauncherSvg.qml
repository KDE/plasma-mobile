import QtQuick 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

Item {
    id: root
    width: parent.width / parent.columns
    height: parent.buttonHeight
    property var callback
    property string text
    property string sub
    property alias svg: icon.svg
    property alias elementId: icon.elementId

    PlasmaCore.SvgItem{
        id: icon
        width: units.iconSizes.medium
        height: width
        anchors.centerIn: parent
    }

    MouseArea {
        anchors.fill: parent
        propagateComposedEvents: true
        drag.target: stripe
        drag.axis: Drag.YAxis
        onClicked: {
            if (callback) {
                callback();
            } else {
                addNumber(parent.text);
            }
        }
    }
}
