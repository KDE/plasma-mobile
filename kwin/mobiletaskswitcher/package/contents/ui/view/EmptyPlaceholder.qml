// SPDX-FileCopyrightText: 2021-2024 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import org.kde.kirigami as Kirigami
import org.kde.plasma.private.mobileshell.taskswitcherplugin as TaskSwitcherPlugin
import "../logic"

ColumnLayout {
    id: root

    required property TaskSwitcher taskSwitcher
    readonly property TaskSwitcherController controller: taskSwitcher.controller

    spacing: Kirigami.Units.gridUnit

    opacity: {
        let baseOpacity = ((taskSwitcher.tasksCount === 0 && !taskSwitcher.state.closing) ? 0.9 : 0);
        return controller.gesture.intent === TaskSwitcherPlugin.TaskSwitcherGesture.Intent.TaskSwitcher ? baseOpacity : 0;
    }
    Behavior on opacity { NumberAnimation { duration: Kirigami.Units.veryLongDuration } }

    Kirigami.Icon {
        Layout.alignment: Qt.AlignHCenter
        implicitWidth: Kirigami.Units.iconSizes.large
        implicitHeight: Kirigami.Units.iconSizes.large
        source: "edit-none-symbolic"
        color: "white"
    }

    Kirigami.Heading {
        Layout.fillWidth: true
        Layout.maximumWidth: root.taskSwitcher.width * 0.75
        Layout.alignment: Qt.AlignHCenter
        color: "white"
        level: 3
        wrapMode: Text.Wrap
        horizontalAlignment: Text.AlignHCenter
        text: i18n("No applications are running.")
    }
}
