/*
SPDX-FileCopyrightText: 2020-2021 Devin Lin <espidev@gmail.com>

SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.12
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.12
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.workspace.keyboardlayout 1.0
import org.kde.kirigami 2.12 as Kirigami

Rectangle {
    id: keypadRoot
    
    // 0 - keypad is not shown, 1 - keypad is shown
    property double swipeProgress
    
    // slightly translucent background, for key contrast
    color: Kirigami.ColorUtils.adjustColor(PlasmaCore.Theme.backgroundColor, {"alpha": 0.9*255})
    property string pinLabel: qsTr("Enter PIN")
    
    // for displaying temporary number in pin dot display
    property int previewCharIndex: -2 
    
    // if waiting for result of auth
    property bool waitingForAuth: false
    
    // colour calculations
    property color buttonColor: Qt.lighter(PlasmaCore.Theme.backgroundColor, 1.3)
    property color buttonPressedColor: Qt.darker(PlasmaCore.Theme.backgroundColor, 1.08)
    property color buttonTextColor: PlasmaCore.Theme.textColor
    property color dropShadowColor: Qt.darker(PlasmaCore.Theme.backgroundColor, 1.2)
    property color headerBackgroundColor: Qt.lighter(PlasmaCore.Theme.backgroundColor, 1.3)
    
    opacity: Math.sin((Math.PI / 2) * swipeProgress + 1.5 * Math.PI) + 1
    
    implicitHeight: passwordBar.isPinMode ? PlasmaCore.Units.gridUnit * 17 : passwordBar.implicitHeight
    Behavior on implicitHeight {
        NumberAnimation {
            duration: Kirigami.Units.longDuration
            easing.type: Easing.InOutQuad
        }
    }
    
    signal passwordChanged()
    
    // keypad functions
    function reset() {
        waitingForAuth = false;
        root.password = "";
        passwordChanged();
        keypadRoot.pinLabel = qsTr("Enter PIN");
    }
    
    function backspace() {
        if (!keypadRoot.waitingForAuth) {
            keypadRoot.previewCharIndex = -2;
            root.password = root.password.substr(0, root.password.length - 1);
            passwordChanged();
        }
    }

    function clear() {
        if (!keypadRoot.waitingForAuth) {
            keypadRoot.previewCharIndex = -2;
            root.password = "";
            passwordChanged();
        }
    }
    
    function enter() {
        if (root.password !== "") { // prevent typing lock when password is empty
            keypadRoot.waitingForAuth = true;
        }
        
        // don't try to unlock if there is a timeout (unlock once unlocked)
        if (!authenticator.graceLocked) {
            authenticator.tryUnlock(root.password);
        }
    }
    
    function keyPress(data) {
        if (!keypadRoot.waitingForAuth) {
            if (keypadRoot.pinLabel !== qsTr("Enter PIN")) {
                keypadRoot.pinLabel = qsTr("Enter PIN");
            }
            keypadRoot.previewCharIndex = root.password.length;
            root.password += data
            passwordChanged();
            
            // trigger turning letter into dot later
            letterTimer.restart();
        }
    }
    
    Connections {
        target: authenticator
        function onSucceeded() {
            pinLabel = qsTr("Logging in...");
            keypadRoot.waitingForAuth = false;
        }
        function onFailed() {
            root.password = "";
            passwordChanged();
            pinLabel = qsTr("Wrong PIN");
            keypadRoot.waitingForAuth = false;
        }
        function onGraceLockedChanged() {
            // try authenticating if it was waiting for grace lock to stop and it has stopped
            if (!authenticator.graceLocked && keypadRoot.waitingForAuth) {
                authenticator.tryUnlock(root.password);
            }
        }
    }
    
    // listen for keyboard events
    Keys.onPressed: {
        if (event.modifiers === Qt.NoModifier) {
            if (event.key === Qt.Key_Backspace) {
                keypadRoot.backspace();
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                keypadRoot.enter();
            } else if (event.text != "") {
                keypadRoot.keyPress(event.text);
            }
        }
    }
    
    // trigger turning letter into dot after 500 milliseconds
    Timer {
        id: letterTimer
        interval: 500
        running: false
        repeat: false
        onTriggered: {
            keypadRoot.previewCharIndex = -2;
        }
    }
    
    RectangularGlow {
        anchors.topMargin: 1
        anchors.fill: passwordBar
        cached: true
        glowRadius: 4
        spread: 0.2
        color: keypadRoot.dropShadowColor
        opacity: (Math.sin(2*((Math.PI / 2) * keypadRoot.swipeProgress + 1.5 * Math.PI)) + 1)
    }
    
    // pin display and bar
    PasswordBar {
        id: passwordBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        color: keypadRoot.headerBackgroundColor
        opacity: (Math.sin(2*((Math.PI / 2) * keypadRoot.swipeProgress + 1.5 * Math.PI)) + 1)
        
        keypadOpen: swipeProgress === 1
        password: root.password
        previewCharIndex: keypadRoot.previewCharIndex
        pinLabel: keypadRoot.pinLabel
    }
    
    // actual number keys
    ColumnLayout {
        visible: opacity > 0
        opacity: passwordBar.isPinMode ? 1 : 0
        Behavior on opacity {
            NumberAnimation {
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutQuad
            }
        }
        
        anchors {
            left: parent.left
            right: parent.right
            top: passwordBar.bottom
            bottom: parent.bottom
            topMargin: units.gridUnit
            bottomMargin: units.gridUnit
        }
        spacing: units.gridUnit

        GridLayout {
            property string thePw
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Layout.leftMargin: units.gridUnit * 0.5
            Layout.rightMargin: units.gridUnit * 0.5
            Layout.maximumWidth: units.gridUnit * 22
            Layout.maximumHeight: units.gridUnit * 12.5
            columns: 4

            // numpad keys
            Repeater {
                model: ["1", "2", "3", "R", "4", "5", "6", "0", "7", "8", "9", "E"]

                delegate: Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    RectangularGlow {
                        anchors.topMargin: 1
                        anchors.fill: keyRect
                        cornerRadius: keyRect.radius * 2
                        cached: true
                        glowRadius: 2
                        spread: 0.2
                        color: keypadRoot.dropShadowColor
                        opacity: (Math.sin(2*((Math.PI / 2) * keypadRoot.swipeProgress + 1.5 * Math.PI)) + 1)
                    }

                    Rectangle {
                        id: keyRect
                        anchors.centerIn: parent
                        width: parent.width
                        height: parent.height
                        radius: 5
                        color: keypadRoot.buttonColor
                        
                        visible: modelData.length > 0
                        opacity: (Math.sin(2*((Math.PI / 2) * keypadRoot.swipeProgress + 1.5 * Math.PI)) + 1)

                        AbstractButton {
                            anchors.fill: parent
                            onPressedChanged: {
                                if (pressed) {
                                    parent.color = keypadRoot.buttonPressedColor;
                                } else {
                                    parent.color = keypadRoot.buttonColor;
                                }
                            }

                            onClicked: {
                                if (modelData === "R") {
                                    keypadRoot.backspace();
                                } else if (modelData === "E") {
                                    keypadRoot.enter();
                                } else {
                                    keypadRoot.keyPress(modelData);
                                }
                            }
                            onPressAndHold: {
                                if (modelData === "R") {
                                    clear();
                                }
                            }
                        }
                    }

                    PlasmaComponents.Label {
                        visible: modelData !== "R" && modelData !== "E"
                        text: modelData
                        anchors.centerIn: parent
                        font.pointSize: 18
                        font.weight: Font.Light
                        color: keypadRoot.buttonTextColor
                    }

                    PlasmaCore.IconItem {
                        visible: modelData === "R"
                        anchors.centerIn: parent
                        source: "edit-clear"
                    }

                    PlasmaCore.IconItem {
                        visible: modelData === "E"
                        anchors.centerIn: parent
                        source: "go-next"
                    }
                }
            }
        }
    }
}
