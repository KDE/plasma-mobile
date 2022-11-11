// SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick 2.15

import org.kde.plasma.private.mobileshell 1.0 as MobileShell
import org.kde.plasma.private.mobileshell.state 1.0 as MobileShellState
import org.kde.plasma.quicksetting.screenshot 1.0

MobileShell.QuickSetting {
    text: i18n("Screenshot")
    status: i18n("Tap to screenshot")
    icon: "spectacle"
    enabled: false
    
    property bool screenshotRequested: false
    
    function toggle() {
        screenshotRequested = true;
        MobileShellState.Shell.closeActionDrawer();
    }
    
    Connections {
        target: MobileShellState.Shell
        function onActionDrawerVisibleChanged(visible) {
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
