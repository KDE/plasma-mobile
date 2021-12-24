/*
SPDX-FileCopyrightText: 2020 Devin Lin <espidev@gmail.com>

SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.12
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.12

import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.notificationmanager 1.1 as Notifications

import org.kde.kquickcontrolsaddons 2.0 as KQCAddons

// meant to be temporary, until the notifications components in plasma-workspace are available to used
// https://invent.kde.org/plasma/plasma-workspace/-/blob/master/applets/notifications/package/contents/ui/NotificationItem.qml
Item {
    id: notificationItem
    property var notification
    
    anchors.left: parent.left
    anchors.right: parent.right
    height: notifLayout.height + PlasmaCore.Units.gridUnit
    
    opacity: 1 - Math.min(1, 1.5 * Math.abs(rect.x) / width) // opacity during dismiss swipe

    RectangularGlow {
        anchors.topMargin: 1
        anchors.leftMargin: 1
        anchors.fill: rect
        cornerRadius: rect.radius * 2
        glowRadius: 2
        spread: 0.2
        color: "#616161"
    }
    
    // notification
    Rectangle {
        id: rect
        
        radius: 5
        color: "white"
        
        height: parent.height
        width: parent.width
        
        border.color: "#bdbdbd"
        border.width: 1
        ColumnLayout {
            id: notifLayout
            anchors {
                left: parent.left
                leftMargin: PlasmaCore.Units.gridUnit * 0.5
                right: parent.right
                rightMargin: PlasmaCore.Units.gridUnit * 0.5
                verticalCenter: parent.verticalCenter
            }
            RowLayout {
                Layout.fillWidth: true
                spacing: PlasmaCore.Units.smallSpacing / 2
                // notif body
                ColumnLayout {
                    id: textLayout
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                    spacing: PlasmaCore.Units.gridUnit / 2

                    Label {
                        text: notification.summary
                        color: "#212121"
                        Layout.fillWidth: true
                        Layout.preferredHeight: implicitHeight
                        maximumLineCount: 3
                        wrapMode: Text.WordWrap
                        elide: Text.ElideRight
                        font.pointSize: 11
                    }
                    Label {
                        text: notification.body
                        color: "#616161"
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        elide: Text.ElideRight
                        font.pointSize: 10
                    }
                }

                // notification icon
                Item {
                    id: iconContainer

                    Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                    Layout.preferredWidth: PlasmaCore.Units.iconSizes.large
                    Layout.preferredHeight: PlasmaCore.Units.iconSizes.large
                    Layout.topMargin: PlasmaCore.Units.smallSpacing
                    Layout.bottomMargin: PlasmaCore.Units.smallSpacing

                    visible: iconItem.active || imageItem.active

                    PlasmaCore.IconItem {
                        id: iconItem
                        // don't show two identical icons
                        readonly property bool active: valid && source != notification.applicationIconSource
                        anchors.fill: parent
                        usesPlasmaTheme: false
                        smooth: true
                        source: {
                            let icon = notification.icon;
                            if (typeof icon !== "string") return "";
                            if (icon === "dialog-information") return "";
                            return icon;
                        }
                        visible: active
                    }

                    KQCAddons.QImageItem {
                        id: imageItem
                        readonly property bool active: !null && nativeWidth > 0
                        anchors.fill: parent
                        smooth: true
                        fillMode: KQCAddons.QImageItem.PreserveAspectFit
                        visible: active
                        image: typeof notification.icon === "object" ? notification.icon : undefined
                    }
                }
            }

            Flow {
                id: actionsflow
                Layout.fillWidth: true
                spacing: PlasmaCore.Units.smallSpacing
                layoutDirection: Qt.RightToLeft
                Repeater {
                    id: actionRepeater

                    model: {
                        var buttons = [];
                        var actionNames = (notificationItem.notification.actionNames || []);
                        var actionLabels = (notificationItem.notification.actionLabels || []);
                        // HACK We want the actions to be right-aligned but Flow also reverses
                        for (var i = actionNames.length - 1; i >= 0; --i) {
                            buttons.push({
                                actionName: actionNames[i],
                                label: actionLabels[i]
                            });
                        }

                        return buttons;
                    }

                    PlasmaComponents3.ToolButton {
                        flat: false
                        // why does it spit "cannot assign undefined to string" when a notification becomes expired?
                        text: modelData.label || ""

                        onClicked: {
                            if (notificationItem.notification.category === "x-kde.incoming-call") {
                                notifModel.invokeAction(notificationItem.notification.notificationId, modelData.actionName);
                            } else {
                                notificationsRoot.pendingAction = {"notificationId": notificationItem.notification.notificationId,
                                "actionName":modelData.actionName};
                                root.askPassword();
                            }
                        }
                    }
                }
            }
        }

        // swipe gesture for dismissing notification (left/right)
        MouseArea {
            id: dismissSwipe
            anchors.fill: parent
            drag.axis: Drag.XAxis
            drag.target: rect
            onPressed: {
                let pos = mapToItem(actionsflow, mouse.x, mouse.y);
                if (actionsflow.childAt(pos.x, pos.y)) {
                    mouse.accepted = false;
                }
            }
            onReleased: {
                if (Math.abs(rect.x) > width / 2) { // dismiss notification when finished swipe
                    notifModel.close(notificationItem.notification.notificationId);
                } else {
                    slideAnim.restart();
                }
                if (notificationItem.notification.hasDefaultAction && Math.abs(rect.x) < PlasmaCore.Units.gridUnit) {
                    if (notificationItem.notification.category === "x-kde.incoming-call") {
                        notifModel.invokeDefaultAction(notificationItem.notification.notificationId);
                    } else {
                        notificationsRoot.pendingAction = {"notificationId": notificationItem.notification.notificationId,
                        "actionName": ""};
                        root.askPassword();
                    }
                }
            }

            NumberAnimation {
                id: slideAnim
                target: rect
                property: "x"
                to: 0
                duration: PlasmaCore.Units.longDuration
            }
        }
    }
}
