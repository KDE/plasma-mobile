// SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick 2.15

import org.kde.plasma.quicksetting.screenrotation 1.0
import org.kde.plasma.private.mobileshell.quicksettingsplugin as QS

QS.QuickSetting {
    text: i18n("Auto-rotate")
    icon: "rotation-allowed"
    settingsCommand: "plasma-open-settings kcm_kscreen"
    enabled: ScreenRotationUtil.autoScreenRotationEnabled
    available: ScreenRotationUtil.available

    function toggle() {
        ScreenRotationUtil.autoScreenRotationEnabled = !enabled
    }
}
