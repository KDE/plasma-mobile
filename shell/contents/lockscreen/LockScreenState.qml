// SPDX-FileCopyrightText: 2022 Devin Lin <espidev@gmail.com>
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
    
    // the info message given
    property string info: ""
    
    // whether the lockscreen was passwordless
    property bool passwordless: false // TODO true
    
    // whether the device can login with fingerprint
    readonly property bool isFingerprintSupported: authenticator.authenticatorTypes & ScreenLocker.Authenticator.Fingerprint

    signal reset()
    signal unlockSucceeded()
    signal unlockFailed()
    
    function tryPassword() {
        if (root.password !== '') { // prevent typing lock when password is empty
            waitingForAuth = true;
        }
        authenticator.startAuthenticating();
    }
    
    function resetPassword() {
        password = "";
        root.reset();
    }
    
    property var connections: Connections {
        target: authenticator
        
        function onSucceeded() {
            console.log('login succeeded');
            root.waitingForAuth = false;
            root.unlockSucceeded();
            Qt.quit();
        }
        
        function onFailed() {
            console.log('login failed');
            root.waitingForAuth = false;
            root.password = "";
            root.unlockFailed();
        }
        
        function onInfoMessageChanged() {
            console.log('info: ' + authenticator.infoMessage);
            root.info += authenticator.infoMessage + " ";
        }
        
        // TODO
        function onErrorMessageChanged() {
            console.log('error: ' + authenticator.errorMessage);
        }
        
        // TODO
        function onPromptChanged() {
            console.log('prompt: ' + authenticator.prompt);
        }
        
        function onPromptForSecretChanged() {
            console.log('prompt secret: ' + authenticator.promptForSecret);
            if (root.password !== "") {
                authenticator.respond(root.password);
                authenticator.startAuthenticating();
            }
        }
        
    }
}
