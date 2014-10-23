import QtQuick 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kio 1.0 as Kio

MouseArea {
    id: root
    width: applications.cellWidth
    height: width
    onClicked: {
        console.log("Clicked: " + model.entryPath)
        krun.openUrl(model.entryPath)
    }

    Kio.KRun {
        id: krun
    }
    PlasmaCore.IconItem {
        id: icon
        anchors.centerIn: parent
        width: units.iconSizes.large
        height: width
        source: iconName
    }

    Text {
        visible: text.length > 0

        anchors {
            top: icon.bottom
            left: icon.left
            right: icon.right
        }

        wrapMode: Text.WordWrap
        horizontalAlignment: Qt.AlignHCenter
        verticalAlignment: Qt.AlignVCenter

        text: name
        color: "white"
    }
}
