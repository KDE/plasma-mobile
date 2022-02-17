/*
 * SPDX-FileCopyrightText: 2022 Devin Lin <espidev@gmail.com>
 * 
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.12
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.12

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.notificationmanager 1.1 as Notifications
import org.kde.plasma.private.mobileshell 1.0 as MobileShell

Rectangle {
    id: rect
    
    readonly property bool notificationsShown: notificationsList.hasNotifications
    
    property real leftMargin: 0
    property real rightMargin: 0
    property real topMargin: 0
    property real bottomMargin: 0
    
    color: "transparent"
    clip: true
    
    PlasmaCore.ColorScope {
        anchors.fill: parent
        anchors.topMargin: rect.topMargin
        anchors.bottomMargin: rect.bottomMargin
        anchors.leftMargin: rect.leftMargin
        anchors.rightMargin: rect.rightMargin
        colorGroup: PlasmaCore.Theme.NormalColorGroup
        
        Connections {
            target: authenticator
            function onSucceeded() {
                // run pending action if successfully unlocked
                if (notificationsList.requestNotificationAction) {
                    notificationsList.runPendingAction();
                    notificationsList.requestNotificationAction = false;
                }
            }
            function onFailed() {
                notificationsList.requestNotificationAction = false;
            }
        }
        
        MobileShell.NotificationsWidget {
            id: notificationsList
            anchors.fill: parent
            
            historyModelType: MobileShell.NotificationsModelType.WatchedNotificationsModel
            actionsRequireUnlock: true
            historyModel: notifModel
        
            property bool requestNotificationAction: false
            
            onUnlockRequested: {
                requestNotificationAction = true;
                root.askPassword();
            }
        }
    }
}
