// SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick 2.15
import QtQuick.Controls 2.15

import org.kde.kirigami as Kirigami
import org.kde.plasma.components 3.0 as PC3
import org.kde.plasma.private.mobileshell as MobileShell
import org.kde.notificationmanager as NotificationManager

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

    // Component to test
    LockScreen.LockScreen {
        anchors.fill: parent
    }

    // Simulate "overlaid" status bar and quick settings panel
    MobileShell.StatusBar {
        id: statusBar
        z: 1

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        height: Kirigami.Units.gridUnit * 1.25

        Kirigami.Theme.inherit: false
        Kirigami.Theme.colorSet: Kirigami.Theme.Complementary

        backgroundColor: "transparent"

        showSecondRow: false
        showDropShadow: true
        showTime: true
        disableSystemTray: true // prevent SIGABRT, since loading the system tray leads to bad... things
    }

    MobileShell.ActionDrawerOpenSurface {
        anchors.fill: statusBar
        actionDrawer: drawer
        z: 1
    }

    MobileShell.ActionDrawer {
        id: drawer
        z: 1
        anchors.fill: parent
        visible: offset !== 0

        notificationSettings: NotificationManager.Settings {}
        notificationModelType: MobileShell.NotificationsModelType.WatchedNotificationsModel
        notificationModel: NotificationManager.WatchedNotificationsModel {}
    }
}

