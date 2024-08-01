// SPDX-FileCopyrightText: 2022 Devin Lin <espidev@gmail.com>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Layouts

import org.kde.plasma.private.mobileshell as MobileShell
import org.kde.kirigami as Kirigami

import org.kde.notificationmanager as NotificationManager

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

        Item {
            anchors.fill: parent
            anchors.topMargin: root.topMargin
            anchors.bottomMargin: root.bottomMargin
            anchors.leftMargin: root.leftMargin
            anchors.rightMargin: root.rightMargin

            Kirigami.Theme.colorSet: Kirigami.Theme.Window
            Kirigami.Theme.inherit: false

            MobileShell.NotificationsWidget {
                id: notificationsList
                anchors.fill: parent

                historyModelType: MobileShell.NotificationsModelType.WatchedNotificationsModel
                actionsRequireUnlock: true
                historyModel: root.notificationsModel
                notificationSettings: root.notificationSettings
                inLockscreen: true

                property bool requestNotificationAction: false

                onUnlockRequested: {
                    requestNotificationAction = true;
                    root.passwordRequested();
                }
            }
        }
    }
}
