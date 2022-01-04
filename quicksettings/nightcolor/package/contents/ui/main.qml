/*
 *   SPDX-FileCopyrightText: 2015 Marco Martin <notmart@gmail.com>
 *   SPDX-FileCopyrightText: 2021 Devin Lin <espidev@gmail.com>
 *   SPDX-FileCopyrightText: 2021 Aleix Pol Gonzalez <aleixpol@kde.org>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

import org.kde.colorcorrect 0.1 as CC
import org.kde.plasma.private.mobileshell 1.0 as MobileShell
import org.kde.plasma.quicksetting.nightcolor 1.0 as NightColor

MobileShell.QuickSetting {
    text: i18n("Night Color")
    icon: "redshift-status-on"
    enabled: NightColor.NightColorUtil.enabled
    status: ""
    settingsCommand: "plasma-open-settings kcm_nightcolor"

    function toggle() {
        NightColor.NightColorUtil.enabled = !enabled;
    }
}
