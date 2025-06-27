// SPDX-FileCopyrightText: 2025 Florian RICHER <florian.richer@protonmail.com>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick

import org.kde.plasma.private.mobileshell.dpmsplugin as DPMS
import org.kde.plasma.private.mobileshell.state as MobileShellState

QtObject {
    id: root

    function triggerLock() {
        MobileShellState.LockscreenDBusClient.lockScreen();
        __dpms.turnDpmsOff();
    }

    property DPMS.DPMSUtil __dpms: DPMS.DPMSUtil {
        id: dpms
    }
}

