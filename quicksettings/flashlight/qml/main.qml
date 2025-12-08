// SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick 2.15

import org.kde.plasma.quicksetting.flashlight
import org.kde.plasma.private.mobileshell.quicksettingsplugin as QS

QS.QuickSetting {
    text: i18n("Flashlight")
    icon: FlashlightUtil.torchEnabled ? "flashlight-on" : "flashlight-off"
    enabled: FlashlightUtil.torchEnabled
    available: FlashlightUtil.available
    function toggle() {
        FlashlightUtil.toggleTorch()
    }
}
