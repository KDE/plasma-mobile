/*
 *  SPDX-FileCopyrightText: 2024 Micah Stanley <stanleymicah@proton.me>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick
import org.kde.plasma.private.mobileshell as MobileShell

pragma Singleton

/**
 * This wraps the NotificationPopupProvider component so that we can avoid loading side
 * effects from imports (since this is a singleton and initialized immediately on import).
 */
Loader {
    id: root
    sourceComponent: Component {
        MobileShell.NotificationPopupProvider {}
    }

    function load() {
        root.active = true;
    }
}

