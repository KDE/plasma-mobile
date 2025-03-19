// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick

import org.kde.kwin

import org.kde.plasma.private.mobileshell.taskswitcherplugin as TaskSwitcherPlugin
import org.kde.plasma.private.mobileshell.shellsettingsplugin as ShellSettings
import org.kde.plasma.private.mobileshell.state as MobileShellState

SceneEffect {
    id: root

    // Created per screen
    delegate: TaskSwitcher {
        id: taskSwitcher
        state: taskSwitcherState
    }

    ShortcutHandler {
        name: 'Mobile Task Switcher'
        text: i18n('Toggle Mobile Task Switcher')
        sequence: 'Meta+C'

        onActivated: taskSwitcherState.toggle()
    }

    TaskSwitcherPlugin.MobileTaskSwitcherState {
        id: taskSwitcherState

        gestureEnabled: !ShellSettings.Settings.navigationPanelEnabled && !MobileShellState.ShellDBusClient.isActionDrawerOpen && !MobileShellState.ShellDBusClient.isVolumeOSDOpen && !MobileShellState.ShellDBusClient.isNotificationPopupDrawerOpen

        Component.onCompleted: {
            // Initialize with effect
            taskSwitcherState.init(root);
        }
    }
}