/*
 *   SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.1
import QtQuick.Window 2.2

import org.kde.kirigami 2.12 as Kirigami

import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasma5support 2.0 as P5Support
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.private.mobileshell as MobileShell
import org.kde.plasma.private.mobileshell.quicksettingsplugin as QS

/**
 * Root element that contains all the ActionDrawer's contents, and is anchored to the screen.
 */
Item {
    id: root

    required property var actionDrawer
    property QS.QuickSettingsModel quickSettingsModel

    property alias notificationsWidget: notificationWidget

    readonly property real minimizedQuickSettingsOffset: height
    readonly property real maximizedQuickSettingsOffset: height
    readonly property bool isOnLargeScreen: width > quickSettings.width * 2.5
    readonly property real minWidthHeight: Math.min(root.width, root.height)
    readonly property real opacityValue: Math.max(0, Math.min(1, actionDrawer.offset / root.minimizedQuickSettingsOffset))

    Kirigami.Theme.colorSet: Kirigami.Theme.View
    Kirigami.Theme.inherit: false

    // fullscreen background
    Rectangle {
        anchors.fill: parent

        // darken if there are notifications
        color: Qt.rgba(Kirigami.Theme.backgroundColor.r,
                       Kirigami.Theme.backgroundColor.g,
                       Kirigami.Theme.backgroundColor.b,
                       notificationWidget.hasNotifications ? 0.95 : 0.9)
        Behavior on color { ColorAnimation { duration: Kirigami.Units.longDuration } }
        opacity: opacityValue
    }

    P5Support.DataSource {
        id: timeSource
        engine: "time"
        connectedSources: ["Local"]
        interval: 60 * 1000
    }

    MouseArea {
        anchors.fill: parent

        // dismiss drawer when background is clicked
        onClicked: root.actionDrawer.close();

        // left side
        ColumnLayout {
            id: columnLayout

            opacity: opacityValue
            spacing: 0

            anchors {
                top: mediaWidget.bottom
                topMargin: 0
                bottom: parent.bottom
                bottomMargin: 0
                right: quickSettings.left
                left: parent.left
            }
            anchors.margins: minWidthHeight * 0.06

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

                // don't allow notifications widget to get too wide
                Layout.maximumWidth: Kirigami.Units.gridUnit * 25
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.topMargin: minWidthHeight * 0.02
            }
        }

        PlasmaComponents.Label {
            id: clock
            text: Qt.formatTime(timeSource.data.Local.DateTime, MobileShell.ShellUtil.isSystem24HourFormat ? "h:mm" : "h:mm ap")
            verticalAlignment: Qt.AlignVCenter
            opacity: columnLayout.opacity

            anchors {
                left: parent.left
                top: parent.top
                topMargin: columnLayout.anchors.margins / 2
                leftMargin: columnLayout.anchors.margins
            }

            font.pixelSize: Math.min(40, minWidthHeight * 0.1)
            font.weight: Font.ExtraLight
            elide: Text.ElideRight
        }

        PlasmaComponents.Label {
            id: date
            text: Qt.formatDate(timeSource.data.Local.DateTime, "ddd MMMM d")
            verticalAlignment: Qt.AlignTop
            color: Kirigami.Theme.disabledTextColor
            opacity: columnLayout.opacity

            anchors {
                left: parent.left
                top: clock.bottom
                bottom: isOnLargeScreen ? columnLayout.top : mediaWidget.top
                topMargin: Kirigami.Units.smallSpacing
                leftMargin: columnLayout.anchors.margins
            }

            font.pixelSize: Math.min(20, minWidthHeight * 0.05)
            font.weight: Font.Light
        }

        MobileShell.MediaControlsWidget {
            id: mediaWidget
            property real fullHeight: visible ? height + Kirigami.Units.smallSpacing * 6 : 0

            y: isOnLargeScreen ? date.y - height + date.implicitHeight : date.y + date.implicitHeight + columnLayout.anchors.margins / 2

            inActionDrawer: true
            opacity: columnLayout.opacity

            anchors {
                right: quickSettings.left
                left: isOnLargeScreen ? date.right : parent.left
                leftMargin: columnLayout.anchors.margins
                rightMargin: columnLayout.anchors.margins - quickSettings.leftPadding
            }
        }

        // right sidebar
        MobileShell.QuickSettingsPanel {
            id: quickSettings
            height: quickSettings.contentImplicitHeight + quickSettings.topPadding + quickSettings.bottomPadding
            width: intendedWidth

            readonly property real intendedWidth: 360

            property real offsetRatio: quickSettings.height / root.height
            anchors.topMargin: Math.min(root.actionDrawer.offset * offsetRatio - quickSettings.height, 0)
            anchors.top: parent.top
            anchors.right: parent.right

            actionDrawer: root.actionDrawer
            quickSettingsModel: root.quickSettingsModel
            fullScreenHeight: root.height
        }
    }
}
