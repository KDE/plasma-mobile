import QtQuick 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

PlasmaCore.SvgItem {
    id: square
    property int value: 0
    anchors.top: parent.top
    width: parent.width/4
    height: parent.height

    svg: symbolsSvg

    MouseArea {
        anchors.fill: parent
        onPressed: {
            stripe.lockKeyPressed(value);
        }
        onReleased: {
            stripe.lockKeyReleased(value);
        }
    }
}
