/*
 * SPDX-FileCopyrightText: 2021-2022 Devin Lin <espidev@gmail.com>
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.12
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.1

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.private.mobileshell 1.0 as MobileShell

import org.kde.notificationmanager 1.0 as NotificationManager

Item {
    id: root
    required property real openFactor
    required property real statusBarHeight

    property var notificationsModel: []

    signal passwordRequested()

    // top status bar
    MobileShell.StatusBar {
        id: statusBar

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        height: root.statusBarHeight

        colorGroup: PlasmaCore.Theme.ComplementaryColorGroup
        backgroundColor: "transparent"

        showSecondRow: false
        showDropShadow: true
        showTime: false
        disableSystemTray: true // prevent SIGABRT, since loading the system tray on the lockscreen leads to bad... things
    }

    // drag down gesture to open action drawer
    MobileShell.ActionDrawerOpenSurface {
        id: swipeArea
        actionDrawer: drawer
        anchors.fill: statusBar
    }

    // action drawer component
    MobileShell.ActionDrawer {
        id: drawer
        anchors.fill: parent

        visible: offset !== 0
        restrictedPermissions: true

        notificationSettings: NotificationManager.Settings {}
        notificationModel: root.notificationsModel
        notificationModelType: MobileShell.NotificationsModelType.WatchedNotificationsModel

        property bool requestNotificationAction: false

        // notification button clicked, requesting auth
        onPermissionsRequested: {
            requestNotificationAction = true;
            drawer.close();
            root.passwordRequested();
        }
    }

    // listen to authentication events
    Connections {
        target: authenticator
        function onSucceeded() {
            // run pending action if successfully unlocked
            if (drawer.requestNotificationAction) {
                drawer.runPendingAction();
                drawer.requestNotificationAction = false;
            }
        }
        function onFailed() {
            drawer.requestNotificationAction = false;
        }
    }
}
