// SPDX-FileCopyrightText: 2024 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import Qt5Compat.GraphicalEffects

import org.kde.plasma.components 3.0 as PC3
import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.private.mobileshell as MobileShell

import SddmComponents 2.0 as SddmComponents

Item {
    id: root

    // Only show widescreen mode for short height devices (ex. phone landscape)
    readonly property bool isWidescreen: root.height < 720 && (root.height < root.width * 0.75)

    property var greeterState: GreeterState {}

    property var passwordBar: flickableLoader.item ? flickableLoader.item.passwordBar : null

    Kirigami.Theme.inherit: false
    Kirigami.Theme.colorSet: Kirigami.Theme.Complementary

    Component.onCompleted: {
        forceActiveFocus();
    }

    // Listen for keyboard events, and focus on input area
    Keys.onPressed: (event) => {
        if (flickableLoader.item) {
            root.greeterState.isKeyboardMode = true;
            flickableLoader.item.goToOpenPosition();
            passwordBar.textField.forceActiveFocus();

            // Add text from key press
            root.greeterState.password += event.text;
        }
    }

    SddmComponents.Background {
        id: wallpaper
        anchors.fill: parent
        source: "qrc:///theme/background.png"
        fillMode: Image.PreserveAspectCrop
        onStatusChanged: {
            if (status == Image.Error && source != config.defaultBackground) {
                source = config.defaultBackground
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                listView.focus = true;
            }
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
            opacity: flickableLoader.item ? flickableLoader.item.openFactor : 0
        }
    }

    // Animate entrance
    Rectangle {
        id: screenCoverAnim
        z: 1
        color: 'black'
        anchors.fill: parent
        opacity: 1
        visible: opacity > 0

        Behavior on opacity { NumberAnimation { duration: 1000 } }
        Component.onCompleted: opacity = 0
    }

    Connections {
        target: root.greeterState

        // Ensure keypad is opened when password is updated (ex. keyboard)
        function onPasswordChanged() {
            if (root.greeterState.password !== "" && flickableLoader.item) {
                flickableLoader.item.goToOpenPosition();
            }
        }
    }

    Item {
        id: lockscreenContainer
        anchors.fill: parent

        // Header bar and action drawer
        StatusBar {
            id: headerBar
            z: 1
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: Kirigami.Units.gridUnit * 1.25
        }

        // Add loading indicator when not loaded yet
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
            sourceComponent: FlickContainer {
                id: flickable
                property alias passwordBar: keypad.passwordBar

                // Speed up animation when passwordless
                animationDuration: 800

                // Distance to swipe to fully open keypad
                keypadHeight: Kirigami.Units.gridUnit * 20

                Component.onCompleted: {
                    // Go to closed position when loaded
                    flickable.position = 0;
                    flickable.goToClosePosition();
                }

                // Clear entered password after closing keypad
                onOpenFactorChanged: {
                    if (flickable.openFactor < 0.1) {
                        root.passwordBar.clear();
                    }
                }

                MainContent {
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

                    greeterState: root.greeterState

                    anchors.topMargin: headerBar.height
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                }

                // scroll up icon
                Kirigami.Icon {
                    id: scrollUpIconLoader
                    opacity: Math.max(0, 1 - flickable.openFactor * 2)

                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: Kirigami.Units.gridUnit + flickable.position * 0.1
                    anchors.horizontalCenter: parent.horizontalCenter

                    implicitWidth: Kirigami.Units.iconSizes.small
                    implicitHeight: Kirigami.Units.iconSizes.small

                    Kirigami.Theme.colorSet: Kirigami.Theme.Complementary
                    source: "arrow-up"
                }

                Rectangle {
                    id: keypadScrim
                    anchors.fill: parent
                    visible: opacity > 0
                    opacity: flickable.openFactor
                    color: Qt.rgba(0, 0, 0, 0.5)
                }

                MobileShell.LockScreenKeypad {
                    id: keypad
                    anchors.fill: parent
                    openProgress: flickable.openFactor

                    // only show in last 50% of anim
                    opacity: (flickable.openFactor - 0.5) * 2
                    transform: Translate { y: (flickable.keypadHeight - flickable.position) * 0.1 }

                    pinLabel: root.greeterState.pinLabel
                    password: root.greeterState.password
                    waitingForAuth: root.greeterState.waitingForAuth
                    isKeyboardMode: root.greeterState.isKeyboardMode

                    onChangePassword: (password) => { root.greeterState.password = password; }
                    onResetPassword: root.greeterState.resetPassword()
                    onTryPassword: root.greeterState.tryPassword()
                    onResetPinLabel: root.greeterState.resetPinLabel()
                    onChangeKeyboardMode: (isKeyboardMode) => { root.greeterState.isKeyboardMode = isKeyboardMode; }
                }
            }
        }
    }
}