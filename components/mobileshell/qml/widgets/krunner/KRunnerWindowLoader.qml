// SPDX-FileCopyrightText: 2024 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL

import QtQuick
import org.kde.plasma.private.mobileshell as MobileShell

pragma Singleton

/**
 * This wraps the KRunnerWindow component so that we can avoid loading side
 * effects from imports (since this is a singleton and initialized immediately on import).
 */
Loader {
    id: root
    sourceComponent: Component {
        MobileShell.KRunnerWindow {}
    }

    function load() {
        root.active = true;
    }
}
