// SPDX-FileCopyrightText: 2025 Sebastian Kügler <sebas@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQml

import org.kde.plasma.quicksetting.kscreenosd 1.0
import org.kde.plasma.private.mobileshell.shellsettingsplugin as ShellSettings


/**
 * This switches between docked / convergence mode and normal when a monitor
 * is plugged in or unplugged.
 */
QtObject {
    id: component

    property bool initialConvergenceMode: false

    property var apiListener: Connections {
        target: KScreenOSDUtil
        function onOutputsChanged() {
            if (KScreenOSDUtil.outputs > 1) {
                initialConvergenceMode = ShellSettings.Settings.convergenceModeEnabled;
            }
-            console.log("KScreenOSDProvider convergenceModeEnabled: "
-                        + (KScreenOSDUtil.outputs > 1 ? "true" : (initialConvergenceMode ? "TRUE" : "FALSE")));
            ShellSettings.Settings.convergenceModeEnabled = KScreenOSDUtil.outputs > 1 ? true : initialConvergenceMode;
        }
    }

    Component.onCompleted: {
        if (KScreenOSDUtil.outputs < 2) {
            initialConvergenceMode = ShellSettings.Settings.convergenceModeEnabled;
        }
    }
}
