// SPDX-FileCopyrightText: 2022 Devin LIn <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick 2.15
import QtQuick.Controls 2.15

import org.kde.plasma.components 3.0 as PC3
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.private.mobileshell 1.0 as MobileShell
import org.kde.notificationmanager 1.1 as Notifications

import org.kde.notificationmanager 1.0 as NotificationManager

import "../look-and-feel/contents/lockscreen" as LockScreen

// This is a test app for the lockscreen, simulating kscreenlocker.
//
// The "password" in this example is 123456.

ApplicationWindow {
    width: 360
    height: 720
    visible: true
    
    // simulate kscreenlocker wallpaper
    Image {
        id: wallpaper // id passed in by kscreenlocker
        source: "assets/background.jpg"
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
    }
    
    // simulate kscreenlocker authenticator object
    QtObject {
        id: authenticator // id passed in by kscreenlocker
        
        signal succeeded()
        signal failed()
        signal infoMessage(string msg)
        signal errorMessage(string msg)
        signal prompt(string msg)
        signal promptForSecret(string msg)
        
        // these are not kscreenlocker properties, for test purposes only
        property string password: ""
        property bool prompt: true
        
        function tryUnlock() {
            if (prompt) {
                prompt = false;
                promptForSecret("Password:");
            } else if (password === "123456") {
                prompt = true;
                succeeded();
            } else {
                prompt = true;
                failed();
            }
        }
        
        function respond(promptPassword) {
            password = promptPassword;
        }
    }
    
    // component to test
    LockScreen.LockScreen {
        anchors.fill: parent
    }
}

