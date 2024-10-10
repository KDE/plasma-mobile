// SPDX-FileCopyrightText: 2020-2024 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects

import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.workspace.keyboardlayout 1.0
import org.kde.plasma.private.mobileshell as MobileShell

import org.kde.kirigami 2.12 as Kirigami

Item {
    id: root

    required property real openProgress

    // Label to show above the password bar
    required property string pinLabel

    // The current password
    required property string password

    // Whether to grey out the password bar to wait for authentication
    required property bool waitingForAuth

    // Whether we are in keyboard interaction, with the keypad not shown
    required property bool isKeyboardMode

    signal changePassword(string password)
    signal resetPassword()
    signal tryPassword()
    signal resetPinLabel()
    signal changeKeyboardMode(bool isKeyboardMode)

    property alias passwordBar: passwordBar

    MobileShell.HapticsEffect {
        id: haptics
    }

    // Column layout - most cases
    ColumnLayout {
        id: keypadVerticalContainer
        visible: root.height > Kirigami.Units.gridUnit * 25

        anchors.centerIn: parent
        spacing: Kirigami.Units.gridUnit * 2

        LayoutItemProxy {
            id: verticalHeaderProxy
            target: header
        }
        LayoutItemProxy { target: keypadGrid }

        states: [
            State {
                name: "keypad"
                when: !root.isKeyboardMode
                AnchorChanges {
                    target: verticalHeaderProxy; anchors.top: keypadVerticalContainer.top
                }
                PropertyChanges {
                    target: verticalHeaderProxy; anchors.verticalCenterOffset: 0
                }
            },
            State {
                name: "keyboard"
                when: root.isKeyboardMode
                AnchorChanges {
                    target: verticalHeaderProxy; anchors.verticalCenter: keypadVerticalContainer.verticalCenter
                }
                PropertyChanges {
                    target: verticalHeaderProxy; anchors.verticalCenterOffset: -Kirigami.Units.gridUnit * 3
                }
            }
        ]

        transitions: Transition {
            AnchorAnimation {
                easing.type: Easing.OutCirc
                duration: openProgress > 0.5 ? 300 : 0
            }
        }
    }

    // Row layout - used when there is restricted height
    RowLayout {
        id: keypadHorizontalContainer
        visible: !keypadVerticalContainer.visible

        anchors.centerIn: parent
        spacing: Kirigami.Units.gridUnit * 2

        LayoutItemProxy {
            id: horizontalHeaderProxy
            target: header
        }
        LayoutItemProxy { target: keypadGrid }

        states: [
            State {
                name: "keypad"
                when: !root.isKeyboardMode
                AnchorChanges {
                    target: horizontalHeaderProxy; anchors.left: keypadHorizontalContainer.left
                }
            },
            State {
                name: "keyboard"
                when: root.isKeyboardMode
                AnchorChanges {
                    target: horizontalHeaderProxy; anchors.horizontalCenter: keypadHorizontalContainer.horizontalCenter
                }
            }
        ]

        transitions: Transition {
            AnchorAnimation {
                easing.type: Easing.OutCirc
                duration: openProgress > 0.5 ? 300 : 0
            }
        }
    }

    ColumnLayout {
        id: header
        spacing: Kirigami.Units.gridUnit

        // label ("wrong pin", "enter pin")
        Label {
            id: descriptionLabel
            Layout.alignment: Qt.AlignHCenter
            opacity: root.password.length === 0 ? 1 : 0
            text: root.pinLabel
            font.pointSize: 12
            font.bold: true
            color: 'white'

            // Enforce extra margin at top of vertical container
            Layout.topMargin: keypadVerticalContainer.visible ? Kirigami.Units.gridUnit * 3 : 0

            Behavior on opacity {
                NumberAnimation { duration: 200 }
            }
        }

        // pin display and bar
        MobileShell.LockScreenPasswordBar {
            id: passwordBar
            Layout.preferredWidth: Kirigami.Units.gridUnit * 14
            Layout.preferredHeight: Kirigami.Units.gridUnit * 2.5

            isKeypadOpen: root.openProgress >= 0.9
            password: root.password
            waitingForAuth: root.waitingForAuth
            isKeyboardMode: root.isKeyboardMode

            onChangePassword: (password) => root.changePassword(password)
            onResetPassword: root.resetPassword()
            onTryPassword: root.tryPassword()
            onResetPinLabel: root.resetPinLabel()
            onChangeKeyboardMode: (isKeyboardMode) => root.changeKeyboardMode(isKeyboardMode)

            enabled: root.openProgress >= 0.8
        }
    }

    GridLayout {
        id: keypadGrid
        columnSpacing: Kirigami.Units.gridUnit
        rowSpacing: Kirigami.Units.gridUnit
        uniformCellHeights: true
        uniformCellWidths: true

        readonly property real intendedWidth: Kirigami.Units.gridUnit * 14

        Layout.preferredWidth: Kirigami.Units.gridUnit * 14
        Layout.preferredHeight: Kirigami.Units.gridUnit * 22

        readonly property real cellLength: (intendedWidth - columnSpacing * 2) / 3

        columns: 3

        // numpad keys
        Repeater {
            model: ["1", "2", "3", "4", "5", "6", "7", "8", "9", "R", "0", "E"]

            delegate: AbstractButton {
                id: button
                implicitWidth: keypadGrid.cellLength
                implicitHeight: keypadGrid.cellLength
                visible: modelData.length > 0
                enabled: root.openProgress >= 0.8 && !root.isKeyboardMode // Only enable after a certain point in animation

                opacity: enabled
                Behavior on opacity {
                    SequentialAnimation {
                        PauseAnimation { duration: 20 * index }
                        NumberAnimation { duration: 300 }
                    }
                }

                background: Rectangle {
                    readonly property real restingOpacity: (modelData !== "R" && modelData !== "E") ? 0.2 : 0.0
                    radius: width
                    color: Qt.rgba(255, 255, 255,
                                    button.pressed ? 0.5 : restingOpacity)
                }

                onPressedChanged: {
                    if (pressed) {
                        haptics.buttonVibrate();
                    }
                }

                onClicked: {
                    if (modelData === "R") {
                        passwordBar.backspace();
                    } else if (modelData === "E") {
                        passwordBar.enter();
                    } else {
                        passwordBar.keyPress(modelData);
                    }
                }

                onPressAndHold: {
                    if (modelData === "R") {
                        haptics.buttonVibrate();
                        passwordBar.clear();
                    }
                }

                contentItem: Item {
                    PlasmaComponents.Label {
                        visible: modelData !== "R" && modelData !== "E"
                        text: modelData
                        anchors.centerIn: parent
                        font.pointSize: 18
                        color: 'white'
                    }

                    Kirigami.Icon {
                        visible: modelData === "R" || modelData === "E"
                        anchors.centerIn: parent
                        width: Kirigami.Units.iconSizes.small
                        height: Kirigami.Units.iconSizes.small
                        source: modelData === "R" ? "edit-clear" : "go-next"
                        Kirigami.Theme.inherit: false
                        Kirigami.Theme.colorSet: Kirigami.Theme.Complementary
                    }
                }
            }
        }
    }
}
