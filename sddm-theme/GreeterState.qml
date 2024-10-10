// SPDX-FileCopyrightText: 2022-2024 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQml
import QtQuick

QtObject {
    id: root

    // which session to log into
    property int sessionIndex: sessionModel.lastIndex

    // currently selected user
    property string username: ""

    // current password being typed
    property string password: ""

    // whether waiting for authentication after trying password
    property bool waitingForAuth: false

    // the info message given
    property string info: ""

    // whether we are in keyboard mode (hiding the numpad)
    property bool isKeyboardMode: false

    property string pinLabel: enterPinLabel
    readonly property string enterPinLabel: i18n("Enter PIN")
    readonly property string wrongPinLabel: i18n("Wrong PIN")

    signal reset()
    signal unlockSucceeded()
    signal unlockFailed()

    function tryPassword() {
        // prevent typing lock when password is empty
        if (root.password !== '') {
            root.waitingForAuth = true;
        }
        console.log('attempt password');
        sddm.login(root.username, root.password, root.sessionIndex)
    }

    function resetPassword() {
        password = "";
        root.reset();
    }

    function resetPinLabel(): void {
        pinLabel = enterPinLabel;
    }

    property var graceLockTimer: Timer {
        interval: 1000
        onTriggered: {
            root.waitingForAuth = false;
            root.password = "";
        }
    }

    property var connections: Connections {
        target: sddm

        function onLoginFailed() {
            console.log('login failed');
            graceLockTimer.restart();
            root.pinLabel = root.wrongPinLabel;
            root.unlockFailed();
        }

        function onLoginSucceeded() {
            console.log('login succeeded');
            //note SDDM will kill the greeter at some random point after this
            //there is no certainty any transition will finish, it depends on the time it
            //takes to complete the init
            root.waitingForAuth = false;
            root.unlockSucceeded();
        }

        function onInformationMessage(message) {
            console.log(message);
        }
    }
}
