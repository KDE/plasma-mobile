// SPDX-FileCopyrightText: 2022 Yari Polla <skilvingr@gmail.com>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick 2.15

import org.kde.plasma.networkmanagement 0.2 as PlasmaNM
import org.kde.plasma.private.mobileshell 1.0 as MobileShell

MobileShell.QuickSetting {
    id: root

    PlasmaNM.Handler {
        id: nmHandler
    }

    text: i18n("Hotspot")
    icon: "network-wireless-hotspot"

    enabled: false

    function toggle() {
        if (!enabled) {
            nmHandler.createHotspot();
        } else {
            nmHandler.stopHotspot();
        }
    }

    Connections {
        target: nmHandler

        function onHotspotCreated() {
            root.enabled = true;
        }

        function onHotspotDisabled() {
            root.enabled = false;
        }
    }

}
