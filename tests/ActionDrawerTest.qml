/*
 *   SPDX-FileCopyrightText: 2022 Aleix Pol Gonzalez <aleixpol@kde.org>
 *   SPDX-FileCopyrightText: 2022 Devin LIn <devin@kde.org>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Controls 2.15

import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.components 3.0 as PC3
import org.kde.plasma.private.mobileshell as MobileShell

import org.kde.notificationmanager as NotificationManager

// This is a test app to conveniently test the Quick Settings that are available
// on the system without having to load a full Plasma Mobile shell.
//
// Do not expect changes in this file to change the plasma UX. Do not install.
//
// This can be executed by running `qmlscene QuickSettingsTest.qml`

ApplicationWindow {
    width: 360
    height: 720
    visible: true

    Image {
        source: "assets/background.jpg"
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
    }

    MobileShell.StatusBar {
        id: statusBar
        z: 1

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        height: MobileShell.Constants.topPanelHeight

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

    PC3.Label {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Kirigami.Units.gridUnit
        anchors.horizontalCenter: parent.horizontalCenter
        text: "Pull down the action drawer from the top."
        color: "white"
    }
}
