// SPDX-FileCopyrightText: 2021-2024 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.1
import QtQuick.Window 2.2

import org.kde.plasma.private.mobileshell as MobileShell
import org.kde.plasma.components 3.0 as PC3
import org.kde.kirigami as Kirigami
import org.kde.plasma.private.mobileshell.quicksettingsplugin as QS

/**
 * Root element that contains all the ActionDrawer's contents, and is anchored to the screen.
 */
Rectangle {
    id: root

    required property var actionDrawer
    required property QS.QuickSettingsModel quickSettingsModel

    readonly property real minimizedQuickSettingsOffset: contentContainerLoader.minimizedQuickSettingsOffset
    readonly property real maximizedQuickSettingsOffset: contentContainerLoader.maximizedQuickSettingsOffset

    function applyMinMax(val) {
        return Math.max(0, Math.min(1, val));
    }

    Kirigami.Theme.colorSet: Kirigami.Theme.View
    Kirigami.Theme.inherit: false

    // Background color
    color: Qt.rgba(Kirigami.Theme.backgroundColor.r,
                    Kirigami.Theme.backgroundColor.g,
                    Kirigami.Theme.backgroundColor.b,
                    (root.actionDrawer.mode == ActionDrawer.Portrait || notificationWidget.hasNotifications) ? 0.95 : 0.9)
    Behavior on color { ColorAnimation { duration: Kirigami.Units.longDuration } }
    opacity: Math.max(0, Math.min(1, actionDrawer.offset / root.minimizedQuickSettingsOffset))

    // Layout that switches between landscape and portrait mode
    Loader {
        id: contentContainerLoader
        anchors.fill: parent

        readonly property real minimizedQuickSettingsOffset: item ? item.minimizedQuickSettingsOffset : 0
        readonly property real maximizedQuickSettingsOffset: item ? item.maximizedQuickSettingsOffset : 0

        readonly property real offsetDist: root.actionDrawer.offset - minimizedQuickSettingsOffset
        readonly property real totalOffsetDist: maximizedQuickSettingsOffset - minimizedQuickSettingsOffset
        readonly property real minimizedToFullProgress: root.actionDrawer.openToPinnedMode ? (root.actionDrawer.opened ? applyMinMax(offsetDist / totalOffsetDist) : 0) : 1

        asynchronous: true
        sourceComponent: root.actionDrawer.mode == ActionDrawer.Portrait ? portraitContentContainer : landscapeContentContainer
    }

    Component {
        id: portraitContentContainer
        PortraitContentContainer {
            actionDrawer: root.actionDrawer
            width: root.width
            height: root.height

            quickSettings: root.quickSettings
            statusBar: root.statusBar
            mediaControlsWidget: root.mediaControlsWidget
            notificationsWidget: root.notificationsWidget
        }
    }

    Component {
        id: landscapeContentContainer
        LandscapeContentContainer {
            actionDrawer: root.actionDrawer
            width: root.width
            height: root.height

            quickSettings: root.quickSettings
            statusBar: root.statusBar
            mediaControlsWidget: root.mediaControlsWidget
            notificationsWidget: root.notificationsWidget
        }
    }


    // Components shared between the two layouts.
    // This allows us to avoid having to reload the components every time the screen size changes.

    property MobileShell.QuickSettings quickSettings: MobileShell.QuickSettings {
        id: quickSettings
        actionDrawer: root.actionDrawer
        quickSettingsModel: root.quickSettingsModel
        fullViewProgress: (root.actionDrawer.mode == ActionDrawer.Portrait) ? contentContainerLoader.minimizedToFullProgress : 1.0
    }

    property MobileShell.StatusBar statusBar: MobileShell.StatusBar {
        id: statusBar
        Kirigami.Theme.colorSet: Kirigami.Theme.Window
        Kirigami.Theme.inherit: false

        backgroundColor: "transparent"
        showSecondRow: root.actionDrawer.mode == ActionDrawer.Portrait
        showDropShadow: false
        showTime: root.actionDrawer.mode == ActionDrawer.Portrait

        // security reasons, system tray also doesn't work on lockscreen
        disableSystemTray: root.actionDrawer.restrictedPermissions
    }

    property MobileShell.MediaControlsWidget mediaControlsWidget: MobileShell.MediaControlsWidget {
        id: mediaWidget
        inActionDrawer: true
    }

    property MobileShell.NotificationsWidget notificationsWidget: MobileShell.NotificationsWidget {
        id: notificationWidget
        historyModel: root.actionDrawer.notificationModel
        historyModelType: root.actionDrawer.notificationModelType
        notificationSettings: root.actionDrawer.notificationSettings
        actionsRequireUnlock: root.actionDrawer.restrictedPermissions
        onUnlockRequested: root.actionDrawer.permissionsRequested()

        Connections {
            target: root.actionDrawer

            function onRunPendingNotificationAction() {
                notificationWidget.runPendingAction();
            }
        }

        onBackgroundClicked: root.actionDrawer.close();
    }
}