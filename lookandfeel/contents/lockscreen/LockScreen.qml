// SPDX-FileCopyrightText: 2019 Nicolas Fella <nicolas.fella@gmx.de>
// SPDX-FileCopyrightText: 2021-2022 Devin Lin <espidev@gmail.com>
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

    property var lockScreenState: LockScreenState {}
    property var notifModel: Notifications.WatchedNotificationsModel {}

    // only show widescreen mode for short height devices (ex. phone landscape)
    property bool isWidescreen: root.height < 720 && (root.height < root.width * 0.75)
    property bool notificationsShown: false

    readonly property bool drawerOpen: flickable.openFactor >= 1
    property var passwordBar: keypadLoader.item.passwordBar

    // listen for keyboard events, and focus on input area
    Component.onCompleted: forceActiveFocus();
    Keys.onPressed: {
        passwordBar.isPinMode = false;
        flickable.goToOpenPosition();
        passwordBar.textField.forceActiveFocus();
    }

    // wallpaper blur
    Loader {
        anchors.fill: parent
        asynchronous: true
        sourceComponent: WallpaperBlur {
            source: wallpaper
            shouldBlur: root.notificationsShown || root.drawerOpen // only blur once animation finished for performance
        }
    }

    Connections {
        target: root.lockScreenState

        // ensure keypad is opened when password is updated (ex. keyboard)
        function onPasswordChanged() {
            flickable.goToOpenPosition()
        }
    }

    Item {
        anchors.fill: parent

        // header bar and action drawer
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

            property real openFactor: position / keypadHeight

            onOpened: {
                if (root.lockScreenState.passwordless) {
                    // try unlocking if flicked to the top, and we have passwordless login
                    root.lockScreenState.tryPassword();
                }
            }

            keypadHeight: Kirigami.Units.gridUnit * 20

            // go to closed position when loaded
            Component.onCompleted: {
                flickable.position = 0;
                flickable.goToClosePosition();
            }

            // update position, and cap it at the keypad height
            onPositionChanged: {
                if (position > keypadHeight) {
                    position = keypadHeight;
                } else if (position < 0) {
                    position = 0;
                }
            }

            LockScreenNarrowContent {
                id: phoneComponent

                visible: !isWidescreen
                active: visible
                opacity: 1 - flickable.openFactor

                fullHeight: root.height

                lockScreenState: root.lockScreenState
                notificationsModel: root.notifModel
                onNotificationsShownChanged: root.notificationsShown = notificationsShown

                onPasswordRequested: flickable.goToOpenPosition()

                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right

                // move while swiping up
                transform: Translate { y: Math.round((1 - phoneComponent.opacity) * (-root.height / 6)) }
            }

            LockScreenWideScreenContent {
                id: tabletComponent

                visible: isWidescreen
                active: visible
                opacity: 1 - flickable.openFactor

                lockScreenState: root.lockScreenState
                notificationsModel: root.notifModel
                onNotificationsShownChanged: root.notificationsShown = notificationsShown

                onPasswordRequested: flickable.goToOpenPosition()

                anchors.topMargin: headerBarLoader.statusBarHeight
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right

                // move while swiping up
                transform: Translate { y: Math.round((1 - phoneComponent.opacity) * (-root.height / 6)) }
            }

            // scroll up icon
            BottomIconIndicator {
                id: scrollUpIconLoader
                lockScreenState: root.lockScreenState

                anchors.bottom: parent.bottom
                anchors.bottomMargin: Kirigami.Units.gridUnit + flickable.position * 0.5
                anchors.horizontalCenter: parent.horizontalCenter
            }

            // password keypad
            Loader {
                id: keypadLoader
                width: parent.width
                asynchronous: true
                active: !root.lockScreenState.passwordless // only load keypad if not passwordless

                anchors.bottom: parent.bottom

                sourceComponent: ColumnLayout {
                    property alias passwordBar: keypad.passwordBar

                    transform: Translate { y: flickable.keypadHeight - flickable.position }
                    spacing: 0

                    // info notification text
                    Label {
                        Layout.fillWidth: true
                        Layout.rightMargin: Kirigami.Units.largeSpacing
                        Layout.leftMargin: Kirigami.Units.largeSpacing
                        Layout.bottomMargin: Kirigami.Units.smallSpacing * 2
                        font.pointSize: 9

                        elide: Text.ElideRight
                        horizontalAlignment: Text.AlignHCenter
                        text: root.lockScreenState.info
                        opacity: (root.lockScreenState.info.length === 0 || flickable.openFactor < 1) ? 0 : 1
                        color: 'white'

                        Behavior on opacity {
                            NumberAnimation { duration: 200 }
                        }
                    }

                    // scroll down icon
                    Kirigami.Icon {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.bottomMargin: Kirigami.Units.gridUnit
                        implicitWidth: Kirigami.Units.iconSizes.small
                        implicitHeight: Kirigami.Units.iconSizes.small
                        Kirigami.Theme.colorSet: Kirigami.Theme.Complementary
                        source: "arrow-down"
                        opacity: Math.sin((Math.PI / 2) * flickable.openFactor + 1.5 * Math.PI) + 1
                    }

                    Keypad {
                        id: keypad
                        Layout.fillWidth: true
                        focus: true

                        lockScreenState: root.lockScreenState
                        swipeProgress: flickable.openFactor
                    }
                }
            }
        }
    }
}
