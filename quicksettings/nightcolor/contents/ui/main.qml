/*
 *   SPDX-FileCopyrightText: 2015 Marco Martin <notmart@gmail.com>
 *   SPDX-FileCopyrightText: 2021 Devin Lin <espidev@gmail.com>
 *   SPDX-FileCopyrightText: 2021 Aleix Pol Gonzalez <aleixpol@kde.org>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

import org.kde.colorcorrect 0.1 as CC
import org.kde.plasma.private.mobilehomescreencomponents 0.1 as HomeScreenComponents

HomeScreenComponents.QuickSetting {
    text: i18n("Night Color")
    icon: "redshift-status-on"
    enabled: compositorAdaptor.active
    settingsCommand: "plasma-settings -m kcm_nightcolor"

    CC.CompositorAdaptor {
        id: compositorAdaptor
    }
    function toggle() {
        if (compositorAdaptor.active) {
            compositorAdaptor.activeStaged = false;
        } else {
            compositorAdaptor.activeStaged = true;
            compositorAdaptor.modeStaged = 3; // always on
        }
        compositorAdaptor.sendConfigurationAll();
        enabled = compositorAdaptor.active;
    }
}
