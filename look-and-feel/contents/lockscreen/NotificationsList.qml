/*
SPDX-FileCopyrightText: 2020 Devin Lin <espidev@gmail.com>

SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.15
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.12
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.notificationmanager 1.1 as Notifications
import org.kde.kirigami 2.13 as Kirigami
import "../components"

Item {
    id: notificationsRoot
    property alias notificationListHeight: notificationListView.contentHeight
    property int count: notificationListView.count
    clip: true

    property var pendingAction: {"notificationId": 0, "actionName": ""}

    Rectangle {
        z: 1
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        visible: !notificationListView.atYBeginning
        height: PlasmaCore.Units.gridUnit
        gradient: Gradient {
            GradientStop {
                position: 1.0
                color: "transparent"
            }
            GradientStop {
                position: 0.0
                color: Qt.rgba(0, 0, 0, 0.3)
            }
        }
        Rectangle {
            anchors {
                left: parent.left
                right: parent.right
            }
            height: 1
            color: Qt.rgba(1, 1, 1, 0.5)
        }
    }
    Rectangle {
        z: 1
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        visible: !notificationListView.atYEnd
        height: PlasmaCore.Units.gridUnit
        gradient: Gradient {
            GradientStop {
                position: 1.0
                color: Qt.rgba(0, 0, 0, 0.3)
            }
            GradientStop {
                position: 0.0
                color: "transparent"
            }
        }
        Rectangle {
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            height: 1
            color: Qt.rgba(1, 1, 1, 0.5)
        }
    }

    Connections {
        target: authenticator
        function onSucceeded() {
            if (notificationsRoot.pendingAction.notificationId !== 0) {
                if (notificationsRoot.pendingAction.actionName.length == 0) {
                    notifModel.invokeDefaultAction(pendingAction.notificationId);
                } else {
                    notifModel.invokeAction(pendingAction.notificationId, pendingAction.actionName);
                }

                notificationsRoot.pendingAction = {"notificationId": 0, "actionName":""};
            }
        }
        function onFailed() {
            notificationsRoot.pendingAction = {"notificationId": 0, "actionName":""};
        }
    }

    Component {
        id: notificationComponent
        ColumnLayout {
            width: notificationListView.width
            spacing: PlasmaCore.Units.smallSpacing
            
            // insert application heading here once application grouping is implemented
            
            SimpleNotification {
                notification: model
            }
        }
    }
    
    ListView {
        id: notificationListView
        model: notifModel
        
        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
        }
        width: Math.min(PlasmaCore.Units.gridUnit * 25, parent.width - PlasmaCore.Units.gridUnit * 2)
        height: Math.min(contentHeight, parent.height) // don't take up the entire screen for notification list view

        interactive: contentHeight > parent.height // only allow scrolling on notifications list if it is long enough
        opacity: 1 - (passwordFlickable.contentY / passwordFlickable.columnHeight)
        spacing: PlasmaCore.Units.gridUnit
        
        delegate: Kirigami.DelegateRecycler {
            sourceComponent: notificationComponent
        }
        add: Transition {
            NumberAnimation { property: "opacity"; from: 0; to: 1.0; duration: Kirigami.Units.shortDuration }
            NumberAnimation { property: "scale"; from: 0; to: 1.0; duration: Kirigami.Units.shortDuration }
        }
        displaced: Transition {
            NumberAnimation { properties: "x,y"; duration: Kirigami.Units.shortDuration; easing.type: Easing.InOutQuad }
        }
    }
}
