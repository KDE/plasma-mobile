import QtQuick 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

Rectangle {
    anchors.top: parent.top
    color: "#00000000"
    property int value: 0
    property alias elementId: glyph.elementId
    width: parent.width / 4
    height: parent.height

    PlasmaCore.SvgItem {
        id: glyph
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        width: Math.min(parent.height, parent.width)
        height: parent.height

        svg: symbolsSvg
    }
}