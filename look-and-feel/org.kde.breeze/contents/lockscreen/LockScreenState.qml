// SPDX-FileCopyrightText: 2022 Devin Lin <espidev@gmail.com>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQml 2.15
import QtQuick 2.15

QtObject {
    id: root
    
    // current password being typed
    property string password: ""
    
    // whether waiting for authentication after trying password
    property bool waitingForAuth: false
    
    // the info message given
    property string info: ""
    
    // whether the lockscreen was passwordless
    property bool passwordless: true
    
    signal reset()
    signal unlockSucceeded()
    signal unlockFailed()
    
    function tryPassword() {
        if (root.password !== '') { // prevent typing lock when password is empty
            waitingForAuth = true;
        }
        connections.hasPrompt = true;
        authenticator.tryUnlock();
    }
    
    function resetPassword() {
        password = "";
        root.reset();
    }
    
    Component.onCompleted: {
        // determine whether we have passwordless login
        // if we do, authenticator will emit a success signal, otherwise it will emit failure
        authenticator.tryUnlock();
    }
    
    property var connections: Connections {
        target: authenticator
        
        // false for our test of whether we have passwordless login, otherwise it's true
        property bool hasPrompt: false
        
        function onSucceeded() {
            if (hasPrompt) {
                console.log('login succeeded');
                root.waitingForAuth = false;
                root.unlockSucceeded();
                Qt.quit();
            }
        }
        
        function onFailed() {
            root.passwordless = false;
            if (hasPrompt) {
                console.log('login failed');
                root.waitingForAuth = false;
                root.password = "";
                root.unlockFailed();
            }
        }
        
        function onInfoMessage(msg) {
            console.log('info: ' + msg);
            root.info += msg + " ";
        }
        
        // TODO
        function onErrorMessage(msg) {
            console.log('error: ' + msg);
        }
        
        // TODO
        function onPrompt(msg) {
            console.log('prompt: ' + msg);
        }
        
        function onPromptForSecret(msg) {
            console.log('prompt secret: ' + msg);
            authenticator.respond(root.password);
            authenticator.tryUnlock();
        }
        
    }
}
