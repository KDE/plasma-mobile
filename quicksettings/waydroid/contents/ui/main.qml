// SPDX-FileCopyrightText: 2025 Florian RICHER <florian.richer@protonmail.com>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick

import org.kde.plasma.private.mobileshell.quicksettingsplugin as QS
import org.kde.plasma.private.mobileshell as MobileShell
import org.kde.plasma.private.mobileshell.waydroidintegrationplugin as AIP

QS.QuickSetting {
    text: i18nc("@action:button", "Waydroid")
    status: AIP.WaydroidDBusClient.sessionStatus === AIP.WaydroidDBusClient.SessionRunning ? i18nc("@info:status", "Running") : i18nc("@info:status", "Stopped")
    icon: "folder-android-symbolic"
    settingsCommand: "plasma-open-settings kcm_waydroidintegration"

    enabled: AIP.WaydroidDBusClient.sessionStatus === AIP.WaydroidDBusClient.SessionRunning
    available: AIP.WaydroidDBusClient.status === AIP.WaydroidDBusClient.Initialized

    Component.onCompleted: {
        AIP.WaydroidDBusObject.registerObject()
    }

    function toggle(): void {
        if (AIP.WaydroidDBusClient.sessionStatus === AIP.WaydroidDBusClient.SessionRunning) {
            AIP.WaydroidDBusClient.stopSession()
        } else {
            AIP.WaydroidDBusClient.startSession()
        }
    }
}
