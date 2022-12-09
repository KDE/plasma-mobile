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

    property real fullHeight

    signal passwordRequested()

    // avoid topMargin animation when item is being loaded
    onLoaded: loadTimer.restart();
    Timer {
        id: loadTimer
        interval: 200
    }

    // move while swiping up
    transform: Translate { y: Math.round((1 - root.opacity) * (-root.height / 6)) }

    asynchronous: true
    sourceComponent: Item {
        ColumnLayout {
            id: column
            spacing: 0

            // center clock when no notifications are shown, otherwise move the clock upward
            anchors.topMargin: !root.notificationsShown ? Math.round(root.fullHeight / 2 - (column.implicitHeight / 2)) : PlasmaCore.Units.gridUnit * 5
            anchors.bottomMargin: PlasmaCore.Units.gridUnit
            anchors.fill: parent

            // animate
            Behavior on anchors.topMargin {
                NumberAnimation {
                    duration: loadTimer.running ? 0 : PlasmaCore.Units.veryLongDuration
                    easing.type: Easing.InOutExpo
                }
            }

            Clock {
                layoutAlignment: Qt.AlignHCenter
                Layout.alignment: Qt.AlignHCenter
                Layout.bottomMargin: PlasmaCore.Units.gridUnit * 2 // keep spacing even if media controls are gone
            }

            MobileShell.MediaControlsWidget {
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                Layout.maximumWidth: PlasmaCore.Units.gridUnit * 25
                Layout.leftMargin: PlasmaCore.Units.gridUnit
                Layout.rightMargin: PlasmaCore.Units.gridUnit
            }

            NotificationsComponent {
                id: notificationComponent
                lockScreenState: root.lockScreenState
                notificationsModel: root.notificationsModel

                Layout.alignment: Qt.AlignHCenter
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.maximumWidth: PlasmaCore.Units.gridUnit * (25 + 2) // clip margins
                topMargin: PlasmaCore.Units.gridUnit

                onPasswordRequested: root.passwordRequested()
                onNotificationsShownChanged: root.notificationsShown = notificationsShown
            }
        }
    }
}
