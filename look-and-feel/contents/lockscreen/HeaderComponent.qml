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

Loader {
    id: root
    
    required property real openFactor
    
    readonly property real statusBarHeight: PlasmaCore.Units.gridUnit * 1.25
    
    property var notificationsModel: []
    
    signal passwordRequested()
    
    active: true
    asynchronous: true
    
    sourceComponent: Item {
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
            disableSystemTray: true // HACK: prevent SIGABRT
        }
        
        MobileShell.ActionDrawerOpenSurface {
            id: swipeArea
            actionDrawer: drawer
            anchors.fill: statusBar
        }
        
        // swipe-down drawer component
        MobileShell.ActionDrawer {
            id: drawer
            anchors.fill: parent
            
            restrictedPermissions: true
            
            notificationSettings: NotificationManager.Settings {}
            notificationModel: root.notificationsModel
            notificationModelType: MobileShell.NotificationsModelType.WatchedNotificationsModel
            
            property bool requestNotificationAction: false
            
            onPermissionsRequested: {
                requestNotificationAction = true;
                root.passwordRequested();
            }
        }
        
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
