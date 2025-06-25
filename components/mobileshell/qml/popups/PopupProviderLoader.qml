/*
 *  SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
 *  SPDX-FileCopyrightText: 2024-2025 Micah Stanley <stanleymicah@proton.me>
 *
 *  SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL
 */

import QtQuick
import org.kde.plasma.private.mobileshell as MobileShell

pragma Singleton

/**
 * This wraps the popup components so that we can avoid loading side
 * effects from imports (since this is a singleton and initialized immediately on import).
 */
Item {
    id: root

    // WARNING: only call this load from within the plasmashell process, because
    // multiple bindings of the shortcut may break it entirely (hardware volume keys)
    function load() {
        if (!volumeOSD.active) {
            volumeOSD.active = true;
        }
        if (!notifications.active) {
            notifications.active = true;
        }
        if (!actionButtons.active) {
            actionButtons.active = true;
        }
    }

    Loader {
        id: volumeOSD
        sourceComponent: Component {
            MobileShell.VolumeOSDProvider {}
        }
    }

    Loader {
        id: notifications
        sourceComponent: Component {
            MobileShell.NotificationPopupProvider {}
        }
    }

    Loader {
        id: actionButtons
        sourceComponent: Component {
            MobileShell.ActionButtonsProvider {}
        }
    }
}
