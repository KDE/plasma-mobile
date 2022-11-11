// SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick 2.15

import org.kde.plasma.private.mobileshell 1.0 as MobileShell

MobileShell.QuickSetting {
    text: i18n("Sound")
    icon: "audio-speakers-symbolic"
    status: i18n("%1%", MobileShell.AudioProvider.volumeValue) 
    enabled: false
    settingsCommand: "plasma-open-settings kcm_pulseaudio"
    function toggle() {
        MobileShell.AudioProvider.showVolumeOverlay()
    }
}
