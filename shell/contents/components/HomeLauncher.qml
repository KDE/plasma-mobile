import QtQuick 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

MouseArea {
    id: root
    width: applications.cellWidth
    height: width
    onClicked: {
        console.log("Clicked: " + width)
    }

    PlasmaCore.IconItem {
        id: icon
        anchors {
            top: root.top
            horizontalCenter: root.horizontalCenter
        }
        width: units.iconSizes.large
        height: width
        source: iconName
    }

    Text {
        visible: text.length > 0

        anchors {
            top: icon.bottom
            left: parent.left
            right: parent.right
        }

        horizontalAlignment: Qt.AlignHCenter
        verticalAlignment: Qt.AlignVCenter

        font.pixelSize: theme.smallestFont.pointSize
        text: name
        color: "white"
    }
}
