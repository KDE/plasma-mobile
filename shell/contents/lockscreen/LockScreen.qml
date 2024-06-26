// SPDX-FileCopyrightText: 2019 Nicolas Fella <nicolas.fella@gmx.de>
// SPDX-FileCopyrightText: 2021-2024 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import org.kde.plasma.core as PlasmaCore
import org.kde.notificationmanager as Notifications

import org.kde.kirigami 2.12 as Kirigami

/**
 * Lockscreen component that is loaded after the device is locked.
 *
 * Special attention must be paid to ensuring the GUI loads as fast as possible.
 */
Item {
    id: root

    readonly property var lockScreenState: LockScreenState {}
    readonly property var notifModel: Notifications.WatchedNotificationsModel {}

    // Only show widescreen mode for short height devices (ex. phone landscape)
    readonly property bool isWidescreen: root.height < 720 && (root.height < root.width * 0.75)
    property bool notificationsShown: false

    property var passwordBar: keypad.passwordBar

    Component.onCompleted: {
        forceActiveFocus();

        // Go to closed position when loaded
        flickable.position = 0;
        flickable.goToClosePosition();
    }

    // Listen for keyboard events, and focus on input area
    Keys.onPressed: {
        root.lockScreenState.isKeyboardMode = true;
        flickable.goToOpenPosition();
        passwordBar.textField.forceActiveFocus();
    }

    // Wallpaper blur
    Loader {
        anchors.fill: parent
        asynchronous: true
        sourceComponent: WallpaperBlur {
            source: wallpaper
            opacity: flickable.openFactor
        }
    }

    Connections {
        target: root.lockScreenState

        // Ensure keypad is opened when password is updated (ex. keyboard)
        function onPasswordChanged() {
            if (root.lockScreenState.password !== "") {
                flickable.goToOpenPosition();
            }
        }
    }

    Item {
        id: lockscreenContainer
        anchors.fill: parent

        // Header bar and action drawer
        Loader {
            id: headerBarLoader
            z: 1 // on top of flick area
            readonly property real statusBarHeight: Kirigami.Units.gridUnit * 1.25

            anchors.fill: parent
            asynchronous: true

            sourceComponent: HeaderComponent {
                statusBarHeight: headerBarLoader.statusBarHeight
                openFactor: flickable.openFactor
                notificationsModel: root.notifModel
                onPasswordRequested: root.askPassword()
            }
        }

        FlickContainer {
            id: flickable
            anchors.fill: parent

            // Distance to swipe to fully open keypad
            keypadHeight: Kirigami.Units.gridUnit * 20

            // Clear entered password after closing keypad
            onOpenFactorChanged: {
                if (flickable.openFactor < 0.1) {
                    root.passwordBar.clear();
                }
            }

            LockScreenContent {
                id: lockScreenContent

                isVertical: !root.isWidescreen
                opacity: Math.max(0, 1 - flickable.openFactor * 2)
                transform: [
                    Scale {
                        origin.x: lockScreenContent.width / 2
                        origin.y: lockScreenContent.height / 2
                        yScale: 1 - (flickable.openFactor * 2) * 0.1
                        xScale: 1 - (flickable.openFactor * 2) * 0.1
                    }
                ]

                fullHeight: root.height

                lockScreenState: root.lockScreenState
                notificationsModel: root.notifModel
                onNotificationsShownChanged: root.notificationsShown = notificationsShown
                onPasswordRequested: flickable.goToOpenPosition()

                anchors.topMargin: headerBarLoader.statusBarHeight
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
            }

            // scroll up icon
            BottomIconIndicator {
                id: scrollUpIconLoader
                lockScreenState: root.lockScreenState
                opacity: Math.max(0, 1 - flickable.openFactor * 2)

                anchors.bottom: parent.bottom
                anchors.bottomMargin: Kirigami.Units.gridUnit + flickable.position * 0.1
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Rectangle {
                id: keypadScrim
                anchors.fill: parent
                visible: opacity > 0
                opacity: flickable.openFactor
                color: Qt.rgba(0, 0, 0, 0.5)
            }

            Keypad {
                id: keypad
                anchors.fill: parent
                openProgress: flickable.openFactor
                lockScreenState: root.lockScreenState

                // only show in last 50% of anim
                opacity: (flickable.openFactor - 0.5) * 2
                transform: Translate { y: (flickable.keypadHeight - flickable.position) * 0.1 }
            }
        }
    }
}
