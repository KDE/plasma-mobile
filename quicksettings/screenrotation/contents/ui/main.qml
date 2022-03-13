// SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick 2.15

import org.kde.plasma.private.mobileshell 1.0 as MobileShell

MobileShell.QuickSetting {
    text: i18n("Auto-rotate")
    icon: "rotation-allowed"
    settingsCommand: "plasma-open-settings kcm_kscreen"
    enabled: MobileShell.ShellUtil.autoRotateEnabled
    function toggle() {
        MobileShell.ShellUtil.autoRotateEnabled = !enabled
    }
}
