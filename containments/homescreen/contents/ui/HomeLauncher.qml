import QtQuick 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kio 1.0 as Kio
import org.kde.plasma.components 2.0 as PlasmaComponents

MouseArea {
    id: delegateRoot
    width: applicationsView.cellWidth
    height: width
    scale: root.reorderingApps && !drag.target ? 0.6 : 1
    Behavior on scale {
        NumberAnimation {
            duration: units.shortDuration
            easing.type: Easing.InOutQuad
        }
    }
    onClicked: {
        console.log("Clicked: " + model.ApplicationStorageIdRole)
        appListModel.runApplication(model.ApplicationStorageIdRole)
    }
    onPressAndHold: {
        delegateRoot.drag.target = delegateRoot;
        root.reorderingApps = true;
    }
    onReleased: {
        delegateRoot.drag.target = null;
        root.reorderingApps = false;
    }
    onPositionChanged: {
        if (delegateRoot.drag.target) {
            appListModel.setOrder(model.ApplicationOriginalRowRole, (Math.round(GridView.view.width / GridView.view.cellWidth) * Math.round(delegateRoot.y / GridView.view.cellHeight) + Math.round(delegateRoot.x / GridView.view.cellWidth)));
        }
    }

    PlasmaCore.IconItem {
        id: icon
        anchors.centerIn: parent
        width: parent.height / 2
        height: width
        source: model.ApplicationIconRole
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

        text: model.ApplicationNameRole
        font.pixelSize: theme.smallestFont.pixelSize
        color: PlasmaCore.ColorScope.textColor
    }
}
