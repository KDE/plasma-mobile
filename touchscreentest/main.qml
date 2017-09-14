import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

ApplicationWindow {
    visible: true
    width: 640
    height: 480
    title: qsTr("Hello World")

    function format(text, mouse) {
        return text + " " + Math.round(mouse.x*100)/100 + " " + Math.round(mouse.y*100)/100
    }

    MouseArea {
        anchors.fill: parent
        onPressed: label.text = format("MOUSE PRESS", mouse)
        onPositionChanged: label.text = format("MOUSE Position change", mouse)
        onReleased: label.text = label.text = format("MOUSE Release", mouse)
        onCanceled: label.text = label.text = format("MOUSE Cancel", mouse)
        Label {
            id: label
            anchors.fill:parent
            font.pointSize: 20
            verticalAlignment: Text.AlignHCenter
            horizontalAlignment: Text.AlignVCenter
            wrapMode: Text.WordWrap
        }
    }
}
