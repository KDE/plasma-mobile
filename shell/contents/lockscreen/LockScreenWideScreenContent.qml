// SPDX-FileCopyrightText: 2021-2022 Devin Lin <espidev@gmail.com>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Effects

import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.workspace.keyboardlayout 1.0
import org.kde.notificationmanager as Notifications
import org.kde.plasma.private.mobileshell as MobileShell

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
                leftMargin: Kirigami.Units.gridUnit * 3
            }
            
            ColumnLayout {
                id: tabletLayout
                anchors.centerIn: parent
                spacing: Kirigami.Units.gridUnit
                
                Clock {
                    layoutAlignment: Qt.AlignLeft
                    Layout.alignment: Qt.AlignLeft
                    Layout.fillWidth: true
                    Layout.minimumWidth: Kirigami.Units.gridUnit * 20
                }
                
                MobileShell.MediaControlsWidget {
                    Layout.alignment: Qt.AlignLeft
                    Layout.fillWidth: true
                    Layout.maximumWidth: Kirigami.Units.gridUnit * 25

                    layer.enabled: true
                    layer.effect: MultiEffect {
                        blurMax: 16
                        shadowEnabled: true
                        shadowVerticalOffset: 1
                        shadowOpacity: 0.5
                        shadowColor: Qt.lighter(Kirigami.Theme.backgroundColor, 0.1)
                    }
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
                rightMargin: Kirigami.Units.gridUnit
            }
            
            NotificationsComponent {
                id: notificationComponent
                lockScreenState: root.lockScreenState
                notificationsModel: root.notificationsModel
                
                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.topMargin: Kirigami.Units.gridUnit * 2
                Layout.bottomMargin: Kirigami.Units.gridUnit
                Layout.minimumWidth: Kirigami.Units.gridUnit * 15
                Layout.maximumWidth: Kirigami.Units.gridUnit * 25
                
                leftMargin: Kirigami.Units.gridUnit
                rightMargin: Kirigami.Units.gridUnit
                bottomMargin: Kirigami.Units.gridUnit
                topMargin: Kirigami.Units.gridUnit
                
                onPasswordRequested: root.passwordRequested()
                onNotificationsShownChanged: root.notificationsShown = notificationsShown
            }
        }
    }
}
