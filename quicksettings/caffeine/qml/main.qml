// SPDX-FileCopyrightText: 2022-2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import org.kde.plasma.private.mobileshell.quicksettingsplugin as QS
import org.kde.plasma.private.batterymonitor

QS.QuickSetting {
    text: i18n("Caffeine")
    icon: "system-suspend-hibernate"
    status: enabled ? i18n("Tap to disable sleep suspension") : i18n("Tap to suspend sleep")
    enabled: inhibitionControl.isManuallyInhibited

    InhibitionControl {
        id: inhibitionControl
        isSilent: false
    }

    function toggle() {
        if (enabled) {
            inhibitionControl.uninhibit();
        } else {
            const reason = i18nc("@info", "Plasma Mobile has enabled system-wide inhibition");
            inhibitionControl.inhibit(reason);
        }
    }
}

