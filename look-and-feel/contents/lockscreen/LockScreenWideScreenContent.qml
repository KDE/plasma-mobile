/*
 * SPDX-FileCopyrightText: 2021-2022 Devin Lin <espidev@gmail.com>
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.12
import QtQuick.Layouts 1.1

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.workspace.keyboardlayout 1.0
import org.kde.notificationmanager 1.1 as Notifications
import org.kde.plasma.private.mobileshell 1.0 as MobileShell

Loader {
    id: root
    
    required property var lockScreenState
    property var notificationsModel: []
    
    property bool notificationsShown: false
    
    signal passwordRequested()
    
    asynchronous: true
    sourceComponent: Item {
        Item {
            id: clock
            width: parent.width / 2   
            anchors {
                top: parent.top
                bottom: parent.bottom
                left: parent.left
                leftMargin: PlasmaCore.Units.gridUnit * 3
            }
            
            ColumnLayout {
                id: tabletLayout
                anchors.centerIn: parent
                spacing: PlasmaCore.Units.gridUnit
                
                Clock {
                    layoutAlignment: Qt.AlignLeft
                    Layout.alignment: Qt.AlignLeft
                    Layout.fillWidth: true
                    Layout.minimumWidth: PlasmaCore.Units.gridUnit * 20
                }
                
                MobileShell.MediaControlsWidget {
                    Layout.alignment: Qt.AlignLeft
                    Layout.fillWidth: true
                    Layout.maximumWidth: PlasmaCore.Units.gridUnit * 25
                }
            }
        }
            
        // tablet notifications list
        ColumnLayout {
            id: tabletNotificationsList
            anchors {
                top: parent.top
                bottom: parent.bottom
                left: clock.right
                right: parent.right
                rightMargin: PlasmaCore.Units.gridUnit
            }
            
            NotificationsComponent {
                id: notificationComponent
                lockScreenState: root.lockScreenState
                notificationsModel: root.notificationsModel
                
                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.topMargin: PlasmaCore.Units.gridUnit * 2
                Layout.bottomMargin: PlasmaCore.Units.gridUnit
                Layout.minimumWidth: PlasmaCore.Units.gridUnit * 15
                Layout.maximumWidth: PlasmaCore.Units.gridUnit * 25
                
                leftMargin: PlasmaCore.Units.gridUnit
                rightMargin: PlasmaCore.Units.gridUnit
                bottomMargin: PlasmaCore.Units.gridUnit
                topMargin: PlasmaCore.Units.gridUnit
                
                onPasswordRequested: root.passwordRequested()
                onNotificationsShownChanged: root.notificationsShown = notificationsShown
            }
        }
    }
}
