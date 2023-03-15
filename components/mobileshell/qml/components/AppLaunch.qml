// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import org.kde.plasma.private.mobileshell as MobileShell
import org.kde.plasma.private.mobileshell.windowplugin as WindowPlugin

pragma Singleton

QtObject {
    /**
     * Activates an application by storage id if it is already running, or launch the application.
     */
    function launchOrActivateApp(storageId) {
        const launched = WindowPlugin.WindowUtil.activateWindowByStorageId(storageId);

        if (!launched) {
            MobileShell.ShellUtil.launchApp(storageId);
        }
    }
}
