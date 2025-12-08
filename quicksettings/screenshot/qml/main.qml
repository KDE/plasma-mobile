// SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick 2.15

import org.kde.plasma.private.mobileshell.quicksettingsplugin as QS
import org.kde.plasma.private.mobileshell.state as MobileShellState
import org.kde.plasma.quicksetting.screenshot

QS.QuickSetting {
    text: i18n("Screenshot")
    status: i18n("Tap to screenshot")
    icon: "view-fullscreen-symbolic"
    enabled: false

    property bool screenshotRequested: false

    function toggle() {
        screenshotRequested = true;
        MobileShellState.ShellDBusClient.closeActionDrawer();
    }

    Connections {
        target: MobileShellState.ShellDBusClient

        function onIsActionDrawerOpenChanged(visible) {
            if (!visible && screenshotRequested) {
                screenshotRequested = false;
                timer.restart();
            }
        }
    }

    // HACK: KWin's fade effect may have the window ending up being in the screenshot if taken too fast
    Timer {
        id: timer
        interval: 500
        onTriggered: ScreenShotUtil.takeScreenShot()
    }
}
