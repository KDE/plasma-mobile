// SPDX-FileCopyrightText: 2020-2024 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import org.kde.plasma.workspace.keyboardlayout 1.0
import org.kde.plasma.workspace.keyboardlayout 1.0 as Keyboards

import org.kde.kirigami 2.12 as Kirigami

Rectangle {
    id: root
    required property var lockScreenState

    property alias textField: textField

    required property bool isKeypadOpen

    // for displaying temporary number in pin dot display
    property int previewCharIndex: -2

    readonly property color headerTextColor: Qt.rgba(255, 255, 255, 1)
    readonly property color headerTextInactiveColor: Qt.rgba(255, 255, 255, 0.4)

    radius: Kirigami.Units.largeSpacing
    color: Qt.rgba(255, 255, 255, 0.2)

    // model for shown dots
    // we need to use a listmodel to avoid all delegates from reloading
    ListModel {
        id: dotDisplayModel
    }

    // Listen to lockscreen state changes
    Connections {
        target: root.lockScreenState

        function onPasswordChanged() {
            while (root.lockScreenState.password.length < dotDisplayModel.count) {
                dotDisplayModel.remove(dotDisplayModel.count - 1);
            }
            while (root.lockScreenState.password.length > dotDisplayModel.count) {
                dotDisplayModel.append({"char": root.lockScreenState.password.charAt(dotDisplayModel.count)});
            }
        }
    }

    // Keypad functions
    function backspace() {
        if (!lockScreenState.waitingForAuth) {
            root.previewCharIndex = -2;
            lockScreenState.password = lockScreenState.password.substr(0, lockScreenState.password.length - 1);
        }
    }

    function clear() {
        if (!lockScreenState.waitingForAuth) {
            root.previewCharIndex = -2;
            lockScreenState.resetPassword();
        }
    }

    function enter() {
        lockScreenState.tryPassword();

        if (root.isKeypadOpen && root.lockScreenState.isKeyboardMode) {
            // make sure keyboard doesn't close
            openKeyboardTimer.restart();
        }
    }

    function keyPress(data) {
        if (!lockScreenState.waitingForAuth) {
            root.lockScreenState.resetPinLabel();

            root.previewCharIndex = lockScreenState.password.length;
            lockScreenState.password += data

            // trigger turning letter into dot later
            letterTimer.restart();
        }
    }

    // HACK: we have to open the virtual keyboard after a certain amount of time or else it will close anyway
    Timer {
        id: openKeyboardTimer
        interval: 10
        running: false
        repeat: false
        onTriggered: Keyboards.KWinVirtualKeyboard.active = true
    }

    // trigger turning letter into dot after 500 milliseconds
    Timer {
        id: letterTimer
        interval: 500
        running: false
        repeat: false
        onTriggered: {
            root.previewCharIndex = -2;
        }
    }

    // hidden textfield so that the virtual keyboard shows up
    TextField {
        id: textField
        visible: false
        focus: root.isKeypadOpen && root.lockScreenState.isKeyboardMode
        z: 1
        inputMethodHints: Qt.ImhNoPredictiveText

        onFocusChanged: {
            if (focus) {
                Keyboards.KWinVirtualKeyboard.active = true;
            }
        }

        property bool externalEdit: false
        property string prevText: ""

        Connections {
            target: root.lockScreenState

            function onPasswordChanged() {
                if (textField.text != root.lockScreenState.password) {
                    textField.externalEdit = true;
                    textField.text = root.lockScreenState.password;
                }
            }
        }

        onEditingFinished: {
            if (textField.focus) {
                root.enter();
            }
        }

        onTextChanged: {
            if (!externalEdit) {
                if (prevText.length > text.length) { // backspace
                    for (let i = 0; i < (prevText.length - text.length); i++) {
                        root.backspace();
                    }
                } else if (text.length > 0) { // key enter
                    root.keyPress(text.charAt(text.length - 1));
                }
                prevText = text;
            }
            externalEdit = false;
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            // clicking on rectangle opens keyboard if not already open
            if (root.lockScreenState.isKeyboardMode) {
                Keyboards.KWinVirtualKeyboard.active = true;
            }
        }

        // toggle between showing keypad and not
        ToolButton {
            id: keyboardToggle
            Kirigami.Theme.inherit: false
            Kirigami.Theme.colorSet: Kirigami.Theme.Complementary

            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.margins: Kirigami.Units.smallSpacing

            // Don't show if the PIN display overlaps it
            visible: (dotDisplay.width / 2) < ((root.width / 2) - keyboardToggle.width - Kirigami.Units.smallSpacing)

            implicitWidth: height
            icon.name: root.lockScreenState.isKeyboardMode ? "input-dialpad-symbolic" : "input-keyboard-virtual-symbolic"
            icon.color: 'white'
            onClicked: {
                root.lockScreenState.isKeyboardMode = !root.lockScreenState.isKeyboardMode;
                if (root.lockScreenState.isKeyboardMode) {
                    Keyboards.KWinVirtualKeyboard.active = true;
                }
            }
        }

        // PIN font metrics
        FontMetrics {
            id: pinFontMetrics
            font.family: Kirigami.Theme.defaultFont.family
            font.pointSize: 12
        }

        // pin dot display
        ColumnLayout {
            anchors.fill: parent

            ListView {
                id: dotDisplay

                property int dotWidth: 6

                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                Layout.bottomMargin: Math.round(dotWidth / 2)
                Layout.maximumWidth: root.width - (Kirigami.Units.largeSpacing * 2)

                readonly property real delegateHeight: Math.max(pinFontMetrics.height, dotWidth)
                readonly property real delegateWidth: dotWidth

                implicitHeight: delegateHeight
                implicitWidth: count * delegateWidth + spacing * (count - 1)

                orientation: ListView.Horizontal
                spacing: 8
                model: dotDisplayModel

                Behavior on implicitWidth {
                    NumberAnimation { duration: 50 }
                }

                onImplicitWidthChanged: {
                    if (contentWidth > Layout.maximumWidth) {
                        // When character is created and ListView is in overflow,
                        // scroll to the end of the ListView to show it
                        dotDisplay.positionViewAtEnd();
                    }
                }

                delegate: Item {
                    width: dotDisplay.delegateWidth
                    height: dotDisplay.delegateHeight
                    property bool showChar: index === root.previewCharIndex

                    Component.onCompleted: {
                        if (showChar) {
                            charAnimation.to = 1;
                            charAnimation.duration = 75;
                            charAnimation.restart();
                        } else {
                            dotAnimation.to = 1;
                            dotAnimation.restart();
                        }
                    }

                    onShowCharChanged: {
                        if (!showChar) {
                            charAnimation.to = 0;
                            charAnimation.duration = 50;
                            charAnimation.restart();
                            dotAnimation.to = 1;
                            dotAnimation.start();
                        }
                    }

                    Rectangle { // dot
                        id: dot
                        scale: 0
                        width: dotDisplay.dotWidth
                        height: dotDisplay.dotWidth
                        anchors.centerIn: parent
                        radius: width
                        color: lockScreenState.waitingForAuth ? root.headerTextInactiveColor : root.headerTextColor // dim when waiting for auth

                        PropertyAnimation {
                            id: dotAnimation
                            target: dot;
                            property: "scale";
                            duration: 50
                        }
                    }

                    Label { // number/letter
                        id: charLabel
                        scale: 0
                        anchors.centerIn: parent
                        color: lockScreenState.waitingForAuth ? root.headerTextInactiveColor : root.headerTextColor // dim when waiting for auth
                        text: model.char
                        font.pointSize: 12

                        PropertyAnimation {
                            id: charAnimation
                            target: charLabel;
                            property: "scale";
                        }
                    }
                }
            }
        }
    }
}
