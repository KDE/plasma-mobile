// SPDX-FileCopyrightText: 2021-2024 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

pragma ComponentBehavior: Bound

import QtQuick

import org.kde.kirigami as Kirigami
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.private.mobileshell.shellsettingsplugin as ShellSettings
import "../logic"

PlasmaComponents.ToolButton {
    id: root

    required property TaskSwitcher taskSwitcher
    required property TaskList taskList
    readonly property TaskSwitcherController controller: taskSwitcher.controller

    property bool closeRequested: false

    visible: taskSwitcher.tasksCount !== 0 && !controller.isInTaskScrubMode
    enabled: !taskSwitcher.state.closing && !taskSwitcher.state.gestureInProgress

    Kirigami.Theme.inherit: false
    Kirigami.Theme.colorSet: Kirigami.Theme.Complementary

    opacity: (taskSwitcher.state.closing || taskSwitcher.state.gestureInProgress || !controller.taskDrawerOpened) ? 0.0 : 1.0
    Behavior on opacity { NumberAnimation { duration: Kirigami.Units.shortDuration } }

    icon.name: "edit-clear-history"
    font.bold: true

    text: closeRequested ? i18n("Confirm Close All") : i18n("Close All")

    onClicked: {
        if (closeRequested || !ShellSettings.Settings.confirmCloseAllEnabled) {
            taskList.closeAll();
        } else {
            closeRequested = true;
        }
    }
}
