// SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick

import org.kde.plasma.private.mobileshell as MobileShell
import org.kde.plasma.private.mobileshell.state as MobileShellState

MobileShell.QuickSetting {
    text: i18n("Sound")
    icon: "audio-speakers-symbolic"
    status: i18n("%1%", MobileShellState.AudioProvider.volumeValue)
    enabled: false
    settingsCommand: "plasma-open-settings kcm_pulseaudio"
    function toggle() {
        MobileShellState.AudioProvider.showVolumeOverlay()
    }
}
