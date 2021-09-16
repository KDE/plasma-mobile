/*
 *   SPDX-FileCopyrightText: 2021 Bhushan Shah <bshah@kde.org>
 *   SPDX-FileCopyrightText: 2021 Nicolas Fella <nicolas.fella@gmx.de>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

import org.kde.plasma.private.mobilehomescreencomponents 0.1 as HomeScreenComponents
import org.kde.plasma.networkmanagement 0.2 as PlasmaNM

HomeScreenComponents.QuickSetting {
    text: i18n("Airplane Mode")
    icon: "network-flightmode-on"
    enabled: PlasmaNM.Configuration.airplaneModeEnabled

    PlasmaNM.Handler {
        id: nmHandler
    }

    function toggle() {
        nmHandler.enableAirplaneMode(!PlasmaNM.Configuration.airplaneModeEnabled);
        PlasmaNM.Configuration.airplaneModeEnabled = !PlasmaNM.Configuration.airplaneModeEnabled;
    }
}
