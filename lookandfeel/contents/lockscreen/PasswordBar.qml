// SPDX-FileCopyrightText: 2020-2022 Devin Lin <espidev@gmail.com>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import org.kde.plasma.workspace.keyboardlayout 1.0
import org.kde.plasma.workspace.keyboardlayout 1.0 as Keyboards

import org.kde.kirigami 2.12 as Kirigami

Rectangle {
    id: root
    implicitHeight: Kirigami.Units.gridUnit * 2.5
    
    required property var lockScreenState
    
    property alias textField: textField
    
    // toggle between pin and password mode
    property bool isPinMode: true
    
    // for displaying temporary number in pin dot display
    property int previewCharIndex: -2
    
    property string pinLabel: qsTr("Enter PIN")
    
    property bool keypadOpen
    
    readonly property color headerTextColor: Kirigami.ColorUtils.adjustColor(Kirigami.Theme.textColor, {"alpha": 0.75*255})
    readonly property color headerTextInactiveColor: Kirigami.ColorUtils.adjustColor(Kirigami.Theme.textColor, {"alpha": 0.4*255})
    
    // model for shown dots
    // we need to use a listmodel to avoid all delegates from reloading
    ListModel {
        id: dotDisplayModel
    }
    
    Connections {
        target: root.lockScreenState
        
        function onUnlockSucceeded() {
            root.pinLabel = qsTr("Logging in...");
        }
        
        function onUnlockFailed() {
            root.pinLabel = qsTr("Wrong PIN");
        }
        
        function onPasswordChanged() {
            while (root.lockScreenState.password.length < dotDisplayModel.count) {
                dotDisplayModel.remove(dotDisplayModel.count - 1);
            }
            while (root.lockScreenState.password.length > dotDisplayModel.count) {
                dotDisplayModel.append({"char": root.lockScreenState.password.charAt(dotDisplayModel.count)});
            }
        }
    }
    
    // keypad functions
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
        
        if (keypadOpen && !isPinMode) {
            // make sure keyboard doesn't close
            openKeyboardTimer.restart();
        }
    }
    
    function keyPress(data) {
        if (!lockScreenState.waitingForAuth) {
            
            if (root.pinLabel !== qsTr("Enter PIN")) {
                root.pinLabel = qsTr("Enter PIN");
            }
            
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
        focus: keypadOpen && !isPinMode
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
            if (!isPinMode) {
                Keyboards.KWinVirtualKeyboard.active = true;
            }
        }
        
        // toggle between showing keypad and not
        ToolButton {
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.margins: Kirigami.Units.smallSpacing
            implicitWidth: height
            icon.name: root.isPinMode ? "input-keyboard-virtual-symbolic" : "input-dialpad-symbolic"
            onClicked: {
                root.isPinMode = !root.isPinMode;
                if (!root.isPinMode) {
                    Keyboards.KWinVirtualKeyboard.active = true;
                }
            }
        }
        
        // label ("wrong pin", "enter pin")
        Label {
            opacity: root.lockScreenState.password.length === 0 ? 1 : 0
            anchors.centerIn: parent
            text: root.pinLabel
            font.pointSize: 12
            color: root.headerTextColor 
            
            Behavior on opacity {
                NumberAnimation { duration: 200 }
            }
        }
        
        // pin dot display
        ColumnLayout {
            anchors.fill: parent
            
            ListView {
                id: dotDisplay

                property int dotWidth: 6
                
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                Layout.bottomMargin: Math.round(dotWidth / 2)

                implicitHeight: dotWidth
                implicitWidth: count * dotWidth + spacing * (count - 1)

                orientation: ListView.Horizontal
                spacing: 8
                model: dotDisplayModel
                
                Behavior on implicitWidth {
                    NumberAnimation { duration: 50 }
                }

                delegate: Item {
                    width: dotDisplay.dotWidth
                    height: dotDisplay.dotWidth
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
                        anchors.fill: parent
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
