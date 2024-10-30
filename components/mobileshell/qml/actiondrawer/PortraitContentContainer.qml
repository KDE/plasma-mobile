/*
 *   SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.1
import QtQuick.Window 2.2

import org.kde.plasma.private.mobileshell as MobileShell
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.private.mobileshell.quicksettingsplugin as QS

/**
 * Root element that contains all the ActionDrawer's contents, and is anchored to the screen.
 */
Item {
    id: root

    required property var actionDrawer
    property QS.QuickSettingsModel quickSettingsModel

    property alias notificationsWidget: notificationWidget

    // pinned position (disabled when openToPinnedMode is false)
    readonly property real minimizedQuickSettingsOffset: quickSettings.minimizedHeight

    // fully open position
    readonly property real maximizedQuickSettingsOffset: minimizedQuickSettingsOffset + quickSettings.maxAddedHeight

    Kirigami.Theme.colorSet: Kirigami.Theme.View
    Kirigami.Theme.inherit: false

    function applyMinMax(val) {
        return Math.max(0, Math.min(1, val));
    }

    // fullscreen background
    Rectangle {
        anchors.fill: parent
        // darken if there are notifications
        color: Qt.rgba(Kirigami.Theme.backgroundColor.r,
                       Kirigami.Theme.backgroundColor.g,
                       Kirigami.Theme.backgroundColor.b,
                       0.95)
        Behavior on color { ColorAnimation { duration: Kirigami.Units.longDuration } }
        opacity: Math.max(0, Math.min(1, actionDrawer.offset / root.minimizedQuickSettingsOffset))
    }

    MobileShell.QuickSettingsDrawer {
        id: quickSettings
        z: 1 // ensure it's above notifications

        // physically move the drawer when between closed <-> pinned mode
        readonly property real offsetHeight: actionDrawer.openToPinnedMode ? minimizedQuickSettingsOffset : maximizedQuickSettingsOffset
        anchors.topMargin: Math.min(root.actionDrawer.offset - offsetHeight, 0)
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        actionDrawer: root.actionDrawer
        quickSettingsModel: root.quickSettingsModel

        // opacity and move animation (disabled when openToPinnedMode is false)
        property real offsetDist: actionDrawer.offset - minimizedQuickSettingsOffset
        property real totalOffsetDist: maximizedQuickSettingsOffset - minimizedQuickSettingsOffset
        minimizedToFullProgress: actionDrawer.openToPinnedMode ? (actionDrawer.opened ? applyMinMax(offsetDist / totalOffsetDist) : 0) : 1

        // this drawer opens in two stages when pinned mode is enabled:
        // ---
        // stage 1: the transform effect is used, the drawer physically moves down to the pinned mode
        // stage 2: the rectangle increases height to reveal content, but the content stays still
        // when pinned mode is disabled, only stage 1 happens

        // increase height of drawer when between pinned mode <-> maximized mode
        addedHeight: {
            if (!actionDrawer.openToPinnedMode) {
                // if pinned mode disabled, just go to full height
                let progress = (root.actionDrawer.offset - maximizedQuickSettingsOffset) / (quickSettings.maxAddedHeight * 4);
                let effectProgress = Math.atan(Math.max(0, progress));
                return (quickSettings.maxAddedHeight * effectProgress) + quickSettings.maxAddedHeight;
            } else if (!actionDrawer.opened) {
                // over-scroll effect for initial opening
                let progress = (root.actionDrawer.offset - minimizedQuickSettingsOffset) / quickSettings.maxAddedHeight;
                let effectProgress = Math.atan(Math.max(0, progress));
                return quickSettings.maxAddedHeight * 0.25 * effectProgress;
            } else {
                // over-scroll effect for full drawer
                let progress = (root.actionDrawer.offset - maximizedQuickSettingsOffset) / (quickSettings.maxAddedHeight * 4);
                let effectProgress = Math.atan(Math.max(0, progress));
                // as the drawer opens, add height to the rectangle, revealing content
                return (quickSettings.maxAddedHeight * effectProgress) + Math.max(0, Math.min(quickSettings.maxAddedHeight, root.actionDrawer.offset - minimizedQuickSettingsOffset));
            }
        }
    }

    MobileShell.NotificationsWidget {
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

        anchors {
            top: quickSettings.bottom
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
        opacity: applyMinMax(root.actionDrawer.offset / root.minimizedQuickSettingsOffset)

        // HACK: there are weird issues with text rendering black regardless of opacity, just set the text to be invisible once it's out
        visible: opacity > 0.05
    }
}
