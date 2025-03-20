/*
 * SPDX-FileCopyrightText: 2021-2024 Devin Lin <espidev@gmail.com>
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.12
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.1

import org.kde.kirigami as Kirigami
import org.kde.plasma.private.mobileshell as MobileShell
import org.kde.plasma.components 3.0 as PC3

import org.kde.notificationmanager as NotificationManager

Item {
    id: root
    required property real openFactor
    required property real statusBarHeight

    property var notificationsModel: []

    readonly property bool actionDrawerVisible: swipeArea.actionDrawer.intendedToBeVisible

    signal passwordRequested()

    // The status bar and quicksettings take a while to load, don't pause initial lockscreen loading for it
    Timer {
        id: loadTimer
        running: true
        repeat: false
        onTriggered: {
            statusBarLoader.active = true
            actionDrawerLoader.active = true
        }
    }

    // Add loading indicator when status bar has not loaded yet
    PC3.BusyIndicator {
        id: statusBarLoadingIndication
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: Kirigami.Units.smallSpacing
        anchors.rightMargin: Kirigami.Units.smallSpacing
        visible: statusBarLoader.status != Loader.Ready

        implicitHeight: root.statusBarHeight
        implicitWidth: root.statusBarHeight

        Kirigami.Theme.inherit: false
        Kirigami.Theme.colorSet: Kirigami.Theme.Complementary
    }

    // Status bar
    Loader {
        id: statusBarLoader
        active: false
        asynchronous: true
        visible: status == Loader.Ready

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        height: root.statusBarHeight

        sourceComponent: MobileShell.StatusBar {
            id: statusBar

            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: root.statusBarHeight

            Kirigami.Theme.inherit: false
            Kirigami.Theme.colorSet: Kirigami.Theme.Complementary

            backgroundColor: "transparent"

            showSecondRow: false
            showDropShadow: true
            showTime: false
            disableSystemTray: true // prevent SIGABRT, since loading the system tray on the lockscreen leads to bad... things
        }
    }

    // Drag down gesture to open action drawer
    MobileShell.ActionDrawerOpenSurface {
        id: swipeArea
        actionDrawer: actionDrawerLoader.item ? actionDrawerLoader.item.actionDrawer : null

        anchors.fill: statusBarLoader
    }

    // Dynamically load on swipe-down to avoid having to load at start
    Loader {
        id: actionDrawerLoader
        active: false
        asynchronous: true
        visible: status == Loader.Ready

        anchors.fill: parent

        sourceComponent: Item {
            property var actionDrawer: drawer

            // Action drawer component
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
    }
}
