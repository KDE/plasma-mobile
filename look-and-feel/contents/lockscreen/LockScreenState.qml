/*
 * SPDX-FileCopyrightText: 2022 Devin Lin <espidev@gmail.com>
 * 
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQml 2.15
import QtQuick 2.15

QtObject {
    id: root
    
    // current password being typed
    property string password: ""
    
    // whether waiting for authentication after trying password
    property bool waitingForAuth: false
    
    property string info: ""
    
    signal reset()
    signal unlockSucceeded()
    signal unlockFailed()
    
    function tryPassword() {
        if (root.password !== '') { // prevent typing lock when password is empty
            waitingForAuth = true;
        }
        authenticator.tryUnlock();
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
