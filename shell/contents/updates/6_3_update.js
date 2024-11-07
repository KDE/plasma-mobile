// SPDX-FileCopyrightText: 2024 Micah <stanleymicah@proton.me>
// SPDX-License-Identifier: GPL-2.0-or-later

/**
 * Configuration updates for Plasma 6.3
 * - Mobile popup notifications were added, remove the old ones.
 */

let allPanels = panels();
for (var i = 0; i < allPanels.length; i++) {
    if (allPanels[i].type === "org.kde.plasma.mobile.panel") {
        let allWidgetIds = allPanels[i].widgetIds;
        for (var w = 0; w < allWidgetIds.length; w++) {
            let widget = allPanels[i].widgetById(allWidgetIds[w]);
            if (widget.type === "org.kde.plasma.notifications") {
                widget.remove();
            }
        }
    }
}
