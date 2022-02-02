// SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

/**
 * Configuration updates for Plasma 5.24
 * - Panel heights were changed, ensure those are updated
 */

print("Applying shell updates for 5.24...")
for (let i in panels()) {
    print("Found panel of type: " + panels()[i].type);
    if (panels()[i].type === "org.kde.phone.panel") {
        panels()[i].height = 1.25 * gridUnit;
    } else if (panels()[i].type === "org.kde.phone.taskpanel") {
        panels()[i].height = 2 * gridUnit;
    }
}

