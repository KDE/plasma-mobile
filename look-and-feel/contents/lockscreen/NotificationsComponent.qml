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
    color: "transparent"
    clip: true
    
    property real leftMargin: 0
    property real rightMargin: 0
    property real topMargin: 0
    property real bottomMargin: 0
    
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
                if (phoneNotificationsList.requestNotificationAction) {
                    phoneNotificationsList.runPendingAction();
                    phoneNotificationsList.requestNotificationAction = false;
                }
            }
            function onFailed() {
                phoneNotificationsList.requestNotificationAction = false;
            }
        }
        
        MobileShell.NotificationsWidget {
            id: phoneNotificationsList
            anchors.fill: parent
            
            historyModelType: MobileShell.NotificationsModelType.WatchedNotificationsModel
            actionsRequireUnlock: true
            historyModel: notifModel
        
            property bool requestNotificationAction: false
            
            onHasNotificationsChanged: root.notificationsShown = hasNotifications
            onUnlockRequested: {
                requestNotificationAction = true;
                root.askPassword();
            }
        }
    }
}
