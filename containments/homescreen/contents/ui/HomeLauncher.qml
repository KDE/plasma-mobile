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

    Rectangle {
        anchors.fill: parent
        color: PlasmaCore.ColorScope.textColor
        radius: units.gridUnit
        opacity: (delegateItem.drag.target != null) ? 0.4 : 0
        Behavior on opacity {
        NumberAnimation {
            duration: units.longDuration
            easing.type: Easing.InOutQuad
        }
    }
    }
    //animate index change
    onIdxChanged: {
        if (delegateItem.drag.target != null) {
            return;
        }

        if (oldIdx < 0) {
            oldIdx = idx;
            return;
        }

        delegateItem.x = ((oldIdx % 4) * GridView.view.cellWidth) - ((idx % 4) * GridView.view.cellWidth);
        delegateItem.y = (Math.floor(oldIdx / 4) * GridView.view.cellHeight) - (Math.floor(idx / 4) * GridView.view.cellHeight);

        translAnim.running = true;

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

        width: applicationsView.cellWidth
        height: width

        states: [
            State {
                when: delegateItem.drag.target != null
                ParentChange {
                    target: delegateItem
                    parent: delegateRoot.parent
                }
                PropertyChanges {
                    target: delegateItem
                    z: 9999
                }
            }
        ]
        function updateRow() {
            var pos = mapToItem(delegateRoot.parent, 0, 0);

            var newRow = (Math.round(delegateRoot.GridView.view.width / delegateRoot.GridView.view.cellWidth) * Math.round(pos.y / delegateRoot.GridView.view.cellHeight) + Math.round(pos.x / delegateRoot.GridView.view.cellWidth));

            if (model.ApplicationOriginalRowRole != newRow) {
                appListModel.moveItem(model.ApplicationOriginalRowRole, newRow);
            }

        }

        onClicked: {
            console.log("Clicked: " + model.ApplicationStorageIdRole)
            appListModel.runApplication(model.ApplicationStorageIdRole)
            oldX = x
            oldY = y
        }
        onPressAndHold: {
            delegateRoot.GridView.view.draggingItem = delegateItem;
            delegateItem.drag.target = delegateItem;
            root.reorderingApps = true;
        }
        onReleased: {
            delegateRoot.GridView.view.draggingItem = delegateItem;
            delegateItem.drag.target = null;
            root.reorderingApps = false;

            translAnim.running = true;
            autoScrollTimer.running = false;
        }
        onPositionChanged: {
            if (!autoScrollTimer.running && delegateItem.drag.target) {
                updateRow();

                var screenPos = mapToItem(delegateRoot.GridView.view, 0, 0);

                if (applicationsView.contentY > 0 && screenPos.y < root.height / 4) {
                    autoScrollTimer.scrollDown = false;
                    autoScrollTimer.running = true;
                } else if (!applicationsView.atYEnd && screenPos.y > 3 * (root.height / 4)) {
                    autoScrollTimer.scrollDown = true;
                    autoScrollTimer.running = true;
                } else {
                    autoScrollTimer.running = false;
                }
            } else {
                autoScrollTimer.running = false;
            }
        }

        PlasmaCore.IconItem {
            id: icon
            anchors.centerIn: parent
            width: parent.height / 2
            height: width
            source: model.ApplicationIconRole
            scale: root.reorderingApps && !delegateItem.drag.target ? 0.6 : 1
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

            text: model.ApplicationNameRole
            font.pixelSize: theme.smallestFont.pixelSize
            color: PlasmaCore.ColorScope.textColor
        }
    }
}
