// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import QtQuick.Effects

import org.kde.kirigami 2.20 as Kirigami

import org.kde.private.mobile.homescreen.folio 1.0 as Folio
import org.kde.plasma.private.mobileshell.state as MobileShellState
import org.kde.plasma.private.mobileshell as MobileShell
import org.kde.plasma.plasmoid

AbstractDelegate {
    id: root

    shadow: true
    name: application ? application.name : ""

    // This may be null for short periods of time due to model changes
    property Folio.FolioApplication application

    property alias iconItem: icon

    property bool turnToFolder: false
    property bool turnToFolderAnimEnabled: false

    function launchApp() {
        if (!application) {
            return;
        }

        if (application.icon !== "" && !root.application.running) {
            MobileShellState.ShellDBusClient.openAppLaunchAnimationWithPosition(
                Plasmoid.screen,
                application.icon,
                application.name,
                application.storageId,
                root.iconItem.Kirigami.ScenePosition.x + root.iconItem.width/2,
                root.iconItem.Kirigami.ScenePosition.y + root.iconItem.height/2,
                Math.min(root.iconItem.width, root.iconItem.height));
        }

        application.setMinimizedDelegate(root);
        MobileShell.AppLaunch.launchOrActivateApp(application.storageId);
    }

    onAfterClickAnimation: {
        launchApp();
    }

    contentItem: Item {
        height: folio.FolioSettings.delegateIconSize
        width: folio.FolioSettings.delegateIconSize

        // Background for folder creation animation
        Rectangle {
            id: rect
            radius: Kirigami.Units.cornerRadius
            color: Qt.rgba(255, 255, 255, 0.3)
            anchors.fill: parent

            opacity: root.turnToFolder ? 1 : 0
            property real scaleAmount: root.turnToFolder ? 1.2 : 1.0

            Behavior on scaleAmount {
                enabled: root.turnToFolderAnimEnabled
                NumberAnimation { duration: Kirigami.Units.longDuration; easing.type: Easing.InOutQuad }
            }
            Behavior on opacity {
                enabled: root.turnToFolderAnimEnabled
                NumberAnimation { duration: Kirigami.Units.longDuration; easing.type: Easing.InOutQuad }
            }

            transform: Scale {
                origin.x: rect.width / 2
                origin.y: rect.height / 2
                xScale: rect.scaleAmount
                yScale: rect.scaleAmount
            }
        }

        // Application icon
        DelegateAppIcon {
            id: icon
            folio: root.folio
            anchors.fill: parent
            source: root.application ? root.application.icon : ""

            property real scaleAmount: root.turnToFolder ? 0.3 : 1.0
            Behavior on scaleAmount {
                enabled: root.turnToFolderAnimEnabled
                NumberAnimation { duration: root.turnToFolderAnimEnabled ? Kirigami.Units.longDuration : 0; easing.type: Easing.InOutQuad }
            }

            transform: Scale {
                origin.x: icon.width / 2
                origin.y: icon.height / 2
                xScale: icon.scaleAmount
                yScale: icon.scaleAmount
            }

            // Running indicator
            Rectangle {
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    bottom: parent.bottom
                    bottomMargin: -Kirigami.Units.smallSpacing
                }
                visible: root.application && root.application.running
                radius: width
                width: Kirigami.Units.smallSpacing
                height: width
                color: Kirigami.Theme.highlightColor
            }
        }
    }
}
