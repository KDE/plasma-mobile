import QtQuick 2.5
import QtQuick.Layouts 1.2
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kio 1.0 as Kio
import org.kde.plasma.components 2.0 as PlasmaComponents

Item {
    id: delegateRoot

    property int iconSize
    property var modelData: model
    property bool isDropTarget: delegateRoot != dragDelegate && root.reorderingApps && applicationsView.dragData && applicationsView.dragData.ApplicationStorageIdRole == modelData.ApplicationStorageIdRole
    property alias maximumLineCount: label.maximumLineCount

    width: applicationsView.cellWidth
    height: applicationsView.cellHeight

    ColumnLayout {
        anchors {
            left: parent.left
            right: parent.right
            horizontalCenter: parent.horizonalCenter
            verticalCenter: parent.verticalCenter
        }
        opacity: isDropTarget ? 0.3 : 1

        PlasmaCore.IconItem {
            id: icon
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: delegateRoot.iconSize
            Layout.preferredHeight: delegateRoot.iconSize
            usesPlasmaTheme: false
            source: modelData.ApplicationIconRole
            scale: root.reorderingApps && applicationsView.dragData && applicationsView.dragData.ApplicationStorageIdRole != modelData.ApplicationStorageIdRole ? 0.6 : 1
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

            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true
            Layout.leftMargin: units.gridUnit
            Layout.rightMargin: units.gridUnit

            wrapMode: Text.WordWrap
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
            maximumLineCount: 1
            elide: Text.ElideRight

            text: modelData.ApplicationNameRole
            font.pixelSize: theme.defaultFont.pixelSize
            color: PlasmaCore.ColorScope.textColor
        }
    }
}
