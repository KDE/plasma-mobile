// SPDX-FileCopyrightText: 2022-2024 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQml
import QtQuick

import org.kde.kscreenlocker 1.0 as ScreenLocker

QtObject {
    id: root

    // current password being typed
    property string password: ""

    // whether waiting for authentication after trying password
    property bool waitingForAuth: false

    // whether PAM has requested input and is waiting for our response
    property bool promptReady: false

    // whether the user submitted a response that is queued until a PAM prompt is ready
    property bool responsePending: false

    // the info message given
    property string info: ""

    // whether the lockscreen can be unlocked (no password needed, passwordless login)
    readonly property bool canBeUnlocked: authenticator.unlocked

    // whether the device can log in with fingerprint
    readonly property bool isFingerprintSupported: authenticator.authenticatorTypes & ScreenLocker.Authenticator.Fingerprint

    // whether we are in keyboard mode (hiding the numpad)
    property bool isKeyboardMode: false

    property string pinLabel: enterPinLabel
    readonly property string enterPinLabel: i18n("Enter PIN")
    readonly property string wrongPinLabel: i18n("Wrong PIN")

    signal reset()
    signal unlockSucceeded()
    signal unlockFailed()

    Component.onCompleted: {
        promptReady = authenticator.prompt !== "" || authenticator.promptForSecret !== "";
        if (!promptReady) {
            authenticator.startAuthenticating();
        }
    }

    function tryPassword() {
        if (waitingForAuth) {
            return;
        }

        waitingForAuth = true;
        responsePending = true;
        if (promptReady) {
            Qt.callLater(root.respondToPrompt);
        } else {
            retryAuthentication();
        }
    }

    function respondToPrompt() {
        if (!responsePending || !promptReady) {
            return;
        }
        responsePending = false;
        promptReady = false;
        authenticator.respond(password);
    }

    function handlePrompt(message: string): void {
        if (message === "") {
            return;
        }

        promptReady = true;
        if (responsePending) {
            // move to next event loop after kscreenlocker handles
            Qt.callLater(root.respondToPrompt);
        } else if (waitingForAuth) {
            waitingForAuth = false;
            resetPassword();
            pinLabel = message;
        }
    }

    function resetPassword() {
        if (responsePending) {
            responsePending = false;
            waitingForAuth = false;
        }
        password = "";
        root.reset();
    }

    function resetPinLabel(): void {
        pinLabel = enterPinLabel;
    }

    function retryAuthentication(): void {
        if (!canBeUnlocked && !promptReady && (!waitingForAuth || responsePending)) {
            authenticator.startAuthenticating();
        }
    }

    // Retry until a prompt arrives
    property var authenticationRetryTimer: Timer {
        interval: 1000
        repeat: true
        running: !root.canBeUnlocked && !root.promptReady
            && (!root.waitingForAuth || root.responsePending)
        onTriggered: root.retryAuthentication()
    }

    property var connections: Connections {
        target: authenticator

        function onSucceeded() {
            root.responsePending = false;
            root.promptReady = false;
            if (authenticator.hadPrompt) {
                console.log('login succeeded');
                root.waitingForAuth = false;
                root.unlockSucceeded();
                Qt.quit();
            }
        }

        function onFailed(kind: int): void {
            if (kind != 0) { // if this is coming from the noninteractive authenticators
                return;
            }
            console.log('login failed');
            root.responsePending = false;
            root.promptReady = false;
            root.waitingForAuth = false;
            root.resetPassword();
            root.pinLabel = root.wrongPinLabel;
            root.unlockFailed();

            // Let the backend finish handling failure before starting the next
            Qt.callLater(root.retryAuthentication);
        }

        function onInfoMessageChanged() {
            console.log('info: ' + authenticator.infoMessage);
            root.info += authenticator.infoMessage + " ";
        }

        // TODO
        function onErrorMessageChanged() {
            console.log('error: ' + authenticator.errorMessage);
        }

        function onPromptChanged() {
            root.handlePrompt(authenticator.prompt);
        }

        function onPromptForSecretChanged() {
            root.handlePrompt(authenticator.promptForSecret);
        }
    }
}
