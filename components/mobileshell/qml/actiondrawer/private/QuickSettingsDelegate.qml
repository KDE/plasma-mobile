/*
 *   SPDX-FileCopyrightText: 2015 Marco Martin <notmart@gmail.com>
 *   SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.1
import QtQuick.Layouts 1.1

import org.kde.kirigami 2.12 as Kirigami

import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.private.nanoshell 2.0 as NanoShell
import org.kde.plasma.private.mobileshell as MobileShell
import org.kde.plasma.private.mobileshell.state as MobileShellState
import org.kde.plasma.components 3.0 as PlasmaComponents

MobileShell.BaseItem {
    id: root

    required property bool restrictedPermissions

    // Model interface
    required property string text
    required property string status
    required property string icon
    required property bool enabled
    required property string settingsCommand
    required property var toggleFunction

    signal closeRequested()

    // set by children
    property var iconItem

    readonly property color enabledButtonBorderColor: Qt.darker(Kirigami.Theme.highlightColor, 1.25)
    readonly property color disabledButtonBorderColor: Kirigami.ColorUtils.tintWithAlpha(Kirigami.Theme.textColor, Kirigami.Theme.backgroundColor, 0.75)
    readonly property color enabledButtonColor: Kirigami.ColorUtils.tintWithAlpha(Kirigami.Theme.highlightColor, Kirigami.Theme.backgroundColor, 0.6)
    readonly property color enabledButtonPressedColor: Kirigami.ColorUtils.tintWithAlpha(Kirigami.Theme.highlightColor, Kirigami.Theme.backgroundColor, 0.4);
    readonly property color disabledButtonColor: Kirigami.Theme.backgroundColor
    readonly property color disabledButtonPressedColor: Qt.darker(disabledButtonColor, 1.1)

    // scale animation on press
    property real zoomScale: 1
    Behavior on zoomScale {
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutExpo
        }
    }

    transform: Scale {
        origin.x: root.width / 2;
        origin.y: root.height / 2;
        xScale: root.zoomScale
        yScale: root.zoomScale
    }

    function delegateClick() {
        if (root.toggle) {
            root.toggle();
        } else if (root.toggleFunction) {
            root.toggleFunction();
        } else if (root.settingsCommand && !root.restrictedPermissions) {
            closeRequested();

            MobileShellState.ShellDBusClient.openAppLaunchAnimationWithPosition(
                __getCurrentScreenNumber(),
                root.icon,
                root.text,
                'org.kde.mobile.plasmasettings', // settings window id
                -1,
                -1,
                Math.min(root.iconItem.width, root.iconItem.height));
            MobileShell.ShellUtil.executeCommand(root.settingsCommand);
        }
    }

    function delegatePressAndHold() {
        if (root.settingsCommand && !root.restrictedPermissions) {
            closeRequested();
            MobileShellState.ShellDBusClient.openAppLaunchAnimationWithPosition(
                __getCurrentScreenNumber(),
                root.icon,
                root.text,
                'org.kde.mobile.plasmasettings', // settings window id
                -1,
                -1,
                Math.min(root.iconItem.width, root.iconItem.height));
            MobileShell.ShellUtil.executeCommand(root.settingsCommand);
        } else if (root.toggleFunction) {
            root.toggleFunction();
        }
    }

    function __getCurrentScreenNumber() {
        const screens = Qt.application.screens;
        for (let i = 0; i < screens.length; i++) {
            if (screens[i].name === Screen.name) {
                return i;
            }
        }

        return 0;
    }
}
