import QtQuick 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kio 1.0 as Kio
import org.kde.plasma.components 2.0 as PlasmaComponents

Item {
    id: delegateRoot
    width: applicationsView.cellWidth
    height: width

    property int idx: index
    property int oldIdx: -1
    onIdxChanged: {
        if (oldIdx < 0) {
            oldIdx = idx;
            return;
        }
        delegateItem.x = ((oldIdx % 4) * GridView.view.cellWidth) - ((idx % 4) * GridView.view.cellWidth);
        delegateItem.y = (Math.floor(oldIdx / 4) * GridView.view.cellHeight) - (Math.floor(idx / 4) * GridView.view.cellHeight);
        if (!delegateItem.drag.target) {
            translAnim.running = true;
        }
        oldIdx = idx;
    }


    NumberAnimation {
        id: translAnim
        duration: units.longDuration
        easing.type: Easing.InOutQuad
        target: delegateItem
        properties: "x,y"
        to: 0
    }
    MouseArea {
        id: delegateItem
        property int oldX
        property int oldY
        width: applicationsView.cellWidth
        height: width
        scale: root.reorderingApps && !drag.target ? 0.6 : 1
        Behavior on scale {
            NumberAnimation {
                duration: units.shortDuration
                easing.type: Easing.InOutQuad
            }
        }

        onXChanged: {
            oldX = x
            oldY = y
        }
        onClicked: {
            console.log("Clicked: " + model.ApplicationStorageIdRole)
            appListModel.runApplication(model.ApplicationStorageIdRole)
            oldX = x
            oldY = y
        }
        onPressAndHold: {
            delegateItem.drag.target = delegateItem;
            root.reorderingApps = true;
        }
        onReleased: {
            delegateItem.drag.target = null;
            root.reorderingApps = false;

            translAnim.running = true
        }
        onPositionChanged: {
            if (delegateItem.drag.target) {
                var pos = mapToItem(delegateRoot.parent, 0, 0);

                appListModel.moveItem(model.ApplicationOriginalRowRole, (Math.round(delegateRoot.GridView.view.width / delegateRoot.GridView.view.cellWidth) * Math.round(pos.y / delegateRoot.GridView.view.cellHeight) + Math.round(pos.x / delegateRoot.GridView.view.cellWidth)));
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
}
