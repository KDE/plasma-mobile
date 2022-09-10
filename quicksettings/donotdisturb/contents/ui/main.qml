/*
 *   SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.private.mobileshell 1.0 as MobileShell

MobileShell.QuickSetting {
    text: i18n("Do Not Disturb")
    icon: enabled ? "notifications-disabled" : "notifications"
    status: ""
    enabled: MobileShell.TopPanelControls.notificationsWidget && MobileShell.TopPanelControls.notificationsWidget.doNotDisturbModeEnabled
    available: MobileShell.TopPanelControls.notificationsWidget

    function toggle() {
        if (MobileShell.TopPanelControls.notificationsWidget) {
            MobileShell.TopPanelControls.notificationsWidget.toggleDoNotDisturbMode();
        }
    }
}
