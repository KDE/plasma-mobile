// SPDX-FileCopyrightText: 2025 Florian RICHER <florian.richer@protonmail.com>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick

import org.kde.plasma.private.mobileshell.quicksettingsplugin as QS
import org.kde.plasma.private.mobileshell as MobileShell
import org.kde.plasma.private.workspace.waydroidintegrationplugin as AIP

QS.QuickSetting {
    text: i18nc("@action:button", "Waydroid")
    status: statusText()
    icon: "folder-android-symbolic"
    settingsCommand: "plasma-open-settings kcm_waydroidintegration"

    available: AIP.WaydroidDBusClient.status !== AIP.WaydroidDBusClient.NotSupported
    enabled: AIP.WaydroidDBusClient.sessionStatus === AIP.WaydroidDBusClient.SessionRunning

    Component.onCompleted: {
        AIP.WaydroidDBusObject.registerObject()
    }

    function toggle(): void {
        if (AIP.WaydroidDBusClient.status !== AIP.WaydroidDBusClient.Initialized) {
            return
        }

        if (AIP.WaydroidDBusClient.sessionStatus === AIP.WaydroidDBusClient.SessionRunning) {
            AIP.WaydroidDBusClient.stopSession()
        } else {
            AIP.WaydroidDBusClient.startSession()
        }
    }

    function statusText(): string {
        if (AIP.WaydroidDBusClient.status !== AIP.WaydroidDBusClient.Initialized) {
            return i18nc("@info:status", "Not initialized")
        } else if (AIP.WaydroidDBusClient.sessionStatus === AIP.WaydroidDBusClient.SessionRunning) {
            return i18nc("@info:status", "Running")
        } else {
            return i18nc("@info:status", "Stopped")
        }
    }
}
