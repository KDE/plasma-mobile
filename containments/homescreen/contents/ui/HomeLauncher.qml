import QtQuick 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kio 1.0 as Kio
import org.kde.plasma.components 2.0 as PlasmaComponents

Item {
    id: delegateRoot
    width: applicationsView.cellWidth
    height: width

    property var modelData: model

    opacity: root.reorderingApps && delegateRoot.GridView.view.dragData && delegateRoot.GridView.view.dragData.ApplicationStorageIdRole == modelData.ApplicationStorageIdRole ? 0.3 : 1

    PlasmaCore.IconItem {
        id: icon
        anchors.centerIn: parent
        width: parent.height / 2
        height: width
        source: modelData.ApplicationIconRole
        scale: root.reorderingApps && delegateRoot.GridView.view.dragData && delegateRoot.GridView.view.dragData.ApplicationStorageIdRole != modelData.ApplicationStorageIdRole ? 0.6 : 1
        Behavior on scale {
            NumberAnimation {
                duration: units.longDuration
                easing.type: Easing.InOutQuad
            }
        }
    }

    PlasmaComponents.Label {
        id: label
        visible: text.length > 0

        anchors {
            top: icon.bottom
            left: icon.left
            right: icon.right
        }

        wrapMode: Text.WordWrap
        horizontalAlignment: Qt.AlignHCenter
        verticalAlignment: Qt.AlignVCenter
        maximumLineCount: 2

        text: modelData.ApplicationNameRole
        font.pixelSize: theme.smallestFont.pixelSize
        color: PlasmaCore.ColorScope.textColor
    }
}
