// SPDX-FileCopyrightText: 2019 Nicolas Fella <nicolas.fella@gmx.de>
// SPDX-FileCopyrightText: 2021-2024 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import org.kde.plasma.core as PlasmaCore
import org.kde.notificationmanager as Notifications
import org.kde.plasma.private.mobileshell as MobileShell
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

    property var passwordBar: flickableLoader.item ? flickableLoader.item.flickable.passwordBar : null

    Component.onCompleted: {
        forceActiveFocus();
    }

    // Listen for keyboard events, and focus on input area
    Keys.onPressed: (event) => {
        if (flickableLoader.item) {
            root.lockScreenState.isKeyboardMode = true;
            flickableLoader.item.flickable.goToOpenPosition();
            passwordBar.textField.forceActiveFocus();

            passwordBar.keyPress(event.text);
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
            opacity: flickableLoader.item ? flickableLoader.item.flickable.openFactor : 0
        }
    }

    Connections {
        target: root.lockScreenState

        // Ensure keypad is opened when password is updated (ex. keyboard)
        function onPasswordChanged() {
            if (root.lockScreenState.password !== "" && flickableLoader.item) {
                flickableLoader.item.flickable.goToOpenPosition();
            }
        }
    }

    // when screen turns off, reset state
    DPMS.DPMSUtil {
        id: dpms

        onDpmsTurnedOff: (screen) => {
            if (screen.name === Screen.name) {
                if (flickableLoader.item) {
                    flickableLoader.item.flickable.goToClosePosition();
                }
                lockScreenState.resetPassword();
            }
        }
    }

    Item {
        id: lockscreenContainer
        anchors.fill: parent

        // Header bar and action drawer
        HeaderComponent {
            id: headerBar
            z: 1
            anchors.fill: parent
            statusBarHeight: MobileShell.Constants.topPanelHeight
            openFactor: flickableLoader.item ? flickableLoader.item.flickable.openFactor : 0
            notificationsModel: root.notifModel
            onPasswordRequested: root.askPassword()
        }

        // Add loading indicator when status bar has not loaded yet
        PC3.BusyIndicator {
            id: flickableLoadingBusyIndicator
            anchors.centerIn: parent
            visible: flickableLoader.status != Loader.Ready

            implicitHeight: Kirigami.Units.iconSizes.huge
            implicitWidth: Kirigami.Units.iconSizes.huge

            Kirigami.Theme.inherit: false
            Kirigami.Theme.colorSet: Kirigami.Theme.Complementary
        }

        // Load flickable async
        Loader {
            id: flickableLoader

            active: false
            asynchronous: true
            opacity: status == Loader.Ready ? 1 : 0
            visible: opacity > 0
            anchors.fill: parent

            Behavior on opacity {
                NumberAnimation {}
            }

            // This take a while to load, don't pause initial lockscreen and wallpaper loading for it
            Timer {
                id: loadTimer
                running: true
                repeat: false
                onTriggered: {
                    flickableLoader.active = true
                }
            }

            // Container for lockscreen contents
            sourceComponent: Item {
                id: item
                property alias flickable: flickable
                FlickContainer {
                    id: flickable
                    anchors.fill: parent
                    property alias passwordBar: keypad.passwordBar

                    // Speed up animation when passwordless
                    animationDuration: root.lockScreenState.canBeUnlocked ? 400 : 800

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

                    scrollLock: headerBar.actionDrawerVisible || (flickableLoader.item ? flickableLoader.item.flickable.openFactor > 0.2 : false)
                    z: scrollLock ? -1 : 0

                    anchors {
                        //topMargin: headerBar.statusBarHeight
                        top: item.top
                        bottom: item.bottom
                        left: item.left
                        right: item.right
                    }
                }
            }
        }
    }
}
