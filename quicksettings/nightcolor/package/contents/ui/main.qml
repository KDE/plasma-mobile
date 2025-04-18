/*
 *   SPDX-FileCopyrightText: 2015 Marco Martin <notmart@gmail.com>
 *   SPDX-FileCopyrightText: 2021 Devin Lin <espidev@gmail.com>
 *   SPDX-FileCopyrightText: 2021 Aleix Pol Gonzalez <aleixpol@kde.org>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

import org.kde.plasma.quicksetting.nightcolor as NightColor
import org.kde.plasma.private.mobileshell.quicksettingsplugin as QS

QS.QuickSetting {
    text: i18n("Night Color")
    icon: "redshift-status-on"
    enabled: NightColor.NightColorUtil.enabled
    status: ""
    settingsCommand: "plasma-open-settings kcm_nightcolor"

    function toggle() {
        NightColor.NightColorUtil.enabled = !enabled;
    }
}
