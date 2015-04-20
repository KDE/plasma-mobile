
import QtQuick 2.0
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

PlasmaComponents.Label {
    Layout.fillWidth: true
    Layout.fillHeight: true

    //This is 0 to override the Label default height that would cause a binding loop
    height: 0
    horizontalAlignment: Qt.AlignHCenter
    verticalAlignment: Qt.AlignVCenter
    font.pointSize: 1024
    fontSizeMode: Text.VerticalFit

    property alias sub: longHold.text
    property var callback

    MouseArea {
        anchors.fill: parent
        onPressed: voiceCallmanager.startDtmfTone(parent.text);
        onReleased: voiceCallmanager.stopDtmfTone();
        onCanceled: voiceCallmanager.stopDtmfTone();
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

    PlasmaComponents.Label {
        id: longHold
        anchors {
            verticalCenter: parent.verticalCenter
            right: parent.right
        }
        height: parent.height * 0.6
        width: parent.width / 3
        verticalAlignment: Qt.AlignVCenter
        visible: text.length > 0
        opacity: 0.7

        font.pointSize: 1024
        fontSizeMode: Text.Fit
    }
}
