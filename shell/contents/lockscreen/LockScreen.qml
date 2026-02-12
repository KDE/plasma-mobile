// SPDX-FileCopyrightText: 2019 Nicolas Fella <nicolas.fella@gmx.de>
// SPDX-FileCopyrightText: 2021-2024 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import org.kde.plasma.core as PlasmaCore
import org.kde.notificationmanager as Notifications
import org.kde.plasma.private.mobileshell as MobileShell
import org.kde.plasma.private.mobileshell.state as MobileShellState
import org.kde.plasma.private.mobileshell.dpmsplugin as DPMS
import org.kde.plasma.components 3.0 as PC3
import org.kde.plasma.private.mobileshell.shellsettingsplugin as ShellSettings

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
    readonly property bool isWidescreen: root.height < Kirigami.Units.gridUnit * 25 && (root.height < root.width * 0.75)
    property bool notificationsShown: false

    property var passwordBar: flickable.passwordBar

    Component.onCompleted: {
        forceActiveFocus();
    }

    // Listen for keyboard events, and focus on input area
    Keys.onPressed: (event) => {
        root.lockScreenState.isKeyboardMode = true;
        flickable.goToOpenPosition();
        passwordBar.textField.forceActiveFocus();

        passwordBar.keyPress(event.text);
    }

    Connections {
        target: MobileShellState.ShellDBusClient

        function onOpenLockScreenKeypadRequested() {
            flickable.goToOpenPosition();
        }
    }

    // Wallpaper blur
    Loader {
        id: wallpaperLoader
        anchors.fill: parent
        active: false
        asynchronous: true

        // This take a while to load, don't pause initial lockscreen loading for it
        Timer {
            running: true
            repeat: false
            onTriggered: wallpaperLoader.active = true
        }

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

    // when screen turns off, reset state
    DPMS.DPMSUtil {
        id: dpms

        onDpmsTurnedOff: (screen) => {
            if (screen.name === Screen.name) {
                flickable.goToClosePosition();
                lockScreenState.resetPassword();
            }
        }
    }

    // Container for lockscreen contents
    Item {
        id: lockscreenContainer
        anchors.fill: parent

        FlickContainer {
            id: flickable
            anchors.fill: parent
            property alias passwordBar: keypad.passwordBar

            // Speed up animation when passwordless
            animationDuration: Kirigami.Units.veryLongDuration

            // Distance to swipe to fully open keypad
            keypadHeight: Kirigami.Units.gridUnit * 20

            Component.onCompleted: {
                // Go to closed position when loaded
                flickable.position = 0;
                flickable.goToClosePosition();
            }

            // Unlock lockscreen if it's already unlocked and keypad is opened
            onOpened: {
                if (root.lockScreenState.canBeUnlocked) {
                    Qt.quit();
                }
            }

            // Unlock lockscreen if it's already unlocked and keypad is open
            Connections {
                target: root.lockScreenState
                function onCanBeUnlockedChanged() {
                    if (root.lockScreenState.canBeUnlocked && flickable.openFactor > 0.8) {
                        Qt.quit();
                    }
                }
            }

            // Clear entered password after closing keypad
            onOpenFactorChanged: {
                if (flickable.openFactor < 0.1 && !flickable.movingUp) {
                    root.passwordBar.clear();
                }
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

            MouseArea {
                // Disable "double tap to lock" to avoid accidental locking
                // when the keypad is open, and the user is typing their password.
                enabled: flickable.openFactor < 0.1
                anchors.fill: parent

                onDoubleClicked: (mouse) => {
                    if (ShellSettings.KWinSettings.doubleTapWakeup) {
                        deviceLock.triggerLock();
                    }
                }

                MobileShell.DeviceLock {
                    id: deviceLock
                }
            }

            Keypad {
                id: keypad
                visible: !root.lockScreenState.canBeUnlocked // don't show for passwordless login
                anchors.fill: parent
                openProgress: flickable.openFactor
                lockScreenState: root.lockScreenState

                // only show in last 50% of anim
                opacity: (flickable.openFactor - 0.5) * 2
                transform: Translate { y: (flickable.keypadHeight - flickable.position) * 0.1 }
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

            lockScreenState: root.lockScreenState
            notificationsModel: root.notifModel
            onNotificationsShownChanged: root.notificationsShown = notificationsShown
            onPasswordRequested: flickable.goToOpenPosition()

            scrollLock: flickable.openFactor > 0.2
            z: scrollLock ? -1 : 0

            anchors.fill: parent
        }
    }
}
