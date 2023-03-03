/*
 * SPDX-FileCopyrightText: 2022 Devin Lin <espidev@gmail.com>
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.12
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.12

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.notificationmanager 1.1 as Notifications
import org.kde.plasma.private.mobileshell 1.0 as MobileShell

import org.kde.notificationmanager 1.0 as NotificationManager

Loader {
    id: root
    required property var lockScreenState

    property var notificationsModel: []
    property var notificationSettings: NotificationManager.Settings {}

    property real leftMargin: 0
    property real rightMargin: 0
    property real topMargin: 0
    property real bottomMargin: 0
    readonly property bool notificationsShown: item && item.notificationsList.hasNotifications

    property var notificationsList: item ? item.notificationsList : null

    signal passwordRequested()

    // perform delayed loading of notifications
    active: false
    Timer {
        interval: 500
        running: true
        onTriggered: root.active = true
    }

    Connections {
        target: lockScreenState

        function onUnlockSucceeded() {
            // run pending action if successfully unlocked
            if (notificationsList.requestNotificationAction) {
                notificationsList.runPendingAction();
                notificationsList.requestNotificationAction = false;
            }
        }

        function onUnlockFailed() {
            notificationsList.requestNotificationAction = false;
        }
    }

    sourceComponent: Item {
        clip: true

        property alias notificationsList: notificationsList

        PlasmaCore.ColorScope {
            anchors.fill: parent
            anchors.topMargin: root.topMargin
            anchors.bottomMargin: root.bottomMargin
            anchors.leftMargin: root.leftMargin
            anchors.rightMargin: root.rightMargin
            colorGroup: PlasmaCore.Theme.NormalColorGroup

            MobileShell.NotificationsWidget {
                id: notificationsList
                anchors.fill: parent

                historyModelType: MobileShell.NotificationsModelType.WatchedNotificationsModel
                actionsRequireUnlock: true
                historyModel: root.notificationsModel
                notificationSettings: root.notificationSettings

                property bool requestNotificationAction: false

                onUnlockRequested: {
                    requestNotificationAction = true;
                    root.passwordRequested();
                }
            }
        }
    }
}
