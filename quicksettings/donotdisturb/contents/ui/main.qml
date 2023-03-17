/*
 *   SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.private.mobileshell.state 1.0 as MobileShellState
import org.kde.plasma.private.mobileshell.quicksettingsplugin as QS

QS.QuickSetting {
    text: i18n("Do Not Disturb")
    icon: enabled ? "notifications-disabled" : "notifications"
    status: ""
    enabled: MobileShellState.TopPanelControls.notificationsWidget && MobileShellState.TopPanelControls.notificationsWidget.doNotDisturbModeEnabled
    available: MobileShellState.TopPanelControls.notificationsWidget

    function toggle() {
        if (MobileShellState.TopPanelControls.notificationsWidget) {
            MobileShellState.TopPanelControls.notificationsWidget.toggleDoNotDisturbMode();
        }
    }
}
