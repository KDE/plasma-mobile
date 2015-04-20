import QtQuick 2.0
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

Item {
    id: buttonRoot

    Layout.fillWidth: true
    Layout.fillHeight: true

    property var callback
    property string sub
    property alias source: icon.source
    property alias text: label.text

    Row {
        anchors.centerIn: parent
        PlasmaCore.IconItem {
            id: icon
            anchors.verticalCenter: parent.verticalCenter
            width: height
            height: buttonRoot.height * 0.6
        }
        PlasmaComponents.Label {
            id: label
            height: buttonRoot.height
            anchors.verticalCenter: parent.verticalCenter
            font.pointSize: 1024
            fontSizeMode: Text.VerticalFit
        }
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
