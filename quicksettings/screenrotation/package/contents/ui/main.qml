// SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick 2.15

import org.kde.plasma.private.mobileshell 1.0 as MobileShell
import org.kde.plasma.quicksetting.screenrotation 1.0

MobileShell.QuickSetting {
    text: i18n("Auto-rotate")
    icon: "rotation-allowed"
    settingsCommand: "plasma-open-settings kcm_kscreen"
    enabled: ScreenRotationUtil.screenRotationEnabled
    available: ScreenRotationUtil.available
    function toggle() {
        ScreenRotationUtil.screenRotationEnabled = !enabled
    }
}
