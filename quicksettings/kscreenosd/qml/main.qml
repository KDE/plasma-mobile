// SPDX-FileCopyrightText: 2025 Sebastian Kügler <sebas@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick

import org.kde.plasma.quicksetting.kscreenosd
import org.kde.plasma.private.mobileshell.quicksettingsplugin as QS

QS.QuickSetting {
    id: kscreenosd_qs
    text: i18n("Display Config")
    icon: "osd-duplicate"
    settingsCommand: "plasma-open-settings kcm_kscreen"
    status: i18nc("kscreen osd quicksetting", "Tap to set up")
    enabled: false
    available: KScreenOSDUtil.outputs > 1

    Connections {
        target: KScreenOSDUtil
        onOutputsChanged: kscreenosd_qs.available = (KScreenOSDUtil.outputs > 1)
    }

    function toggle() {
        console.log("Showing KScreen OSD");
        KScreenOSDUtil.showKScreenOSD();
    }
}
