// SPDX-FileCopyrightText: 2026 Florian Richer <florian.richer@protonmail.com>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick 2.15

import org.kde.plasma.private.mobileshell.quicksettingsplugin as QS
import org.kde.plasma.quicksetting.grayscale

QS.QuickSetting {
    id: root

    text: i18n("Grayscale")
    icon: "lighttable"

    available: true
    enabled: GrayscaleUtil.grayscaleEnabled

    function toggle() {
        GrayscaleUtil.grayscaleToggle()
    }
}
