// SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick

import org.kde.plasma.private.mobileshell as MobileShell
import org.kde.plasma.private.mobileshell.state as MobileShellState
import org.kde.plasma.private.mobileshell.quicksettingsplugin as QS

QS.QuickSetting {
    text: i18n("Sound")
    icon: MobileShell.AudioInfo.icon
    status: i18n("%1%", MobileShell.AudioInfo.volumeValue)
    enabled: false
    settingsCommand: "plasma-open-settings kcm_pulseaudio"

    function toggle() {
        MobileShellState.ShellDBusClient.closeActionDrawer();
        MobileShellState.ShellDBusClient.showVolumeOSD();
    }
}
