// SPDX-FileCopyrightText: 2025 Micah <stanleymicah@proton.me>
// SPDX-License-Identifier: GPL-2.0-or-later

/**
 * Configuration updates for Plasma 6.4
 * - Previously the taskpanel gets removed when gestures are activate.
 * - However, now the navbar is only set to be invisible so we can still use it for other functions.
 * - This makes sure we load the taskpanel template when the panel is not found.
 */

let panelFound = false

for (let i in panels()) {
    print(panels()[i].type)
    if (allPanels[i].type === "org.kde.plasma.mobile.taskpanel") {
        panelFound = true;
    }
}

if (!panelFound) {
    loadTemplate("org.kde.plasma.mobile.defaultNavigationPanel");
}
