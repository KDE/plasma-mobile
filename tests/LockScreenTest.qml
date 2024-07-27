// SPDX-FileCopyrightText: 2022 Devin LIn <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick 2.15
import QtQuick.Controls 2.15

import org.kde.plasma.components 3.0 as PC3
import org.kde.plasma.private.mobileshell as MobileShell

import "../shell/contents/lockscreen" as LockScreen

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

        property string infoMessage: ""
        property string errorMessage: ""
        property string prompt: ""
        property string promptForSecret: ""

        signal succeeded()
        signal failed()

        // these are not kscreenlocker properties, for test purposes only
        property string password: ""
        property bool shouldPrompt: true

        function startAuthenticating() {
            if (shouldPrompt) {
                shouldPrompt = false;
                promptForSecret = "Password:";
                promptForSecretChanged();
            } else if (password === "123456") {
                shouldPrompt = true;
                succeeded();
            } else {
                shouldPrompt = true;
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

