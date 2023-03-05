// SPDX-FileCopyrightText: 2014-2019 Marco Martin <mart@kde.org>
// SPDX-FileCopyrightText: 2015-2021 Bhushan Shah <bshah@kde.org>
// SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

let topFound = false
let bottomFound = false

for (let i in panels()) {
    print(panels()[i].type)
    if (panels()[i].type === "org.kde.plasma.mobile.panel") {
        topFound = true;
    } else if (panels()[i].type === "org.kde.plasma.mobile.taskpanel") {
        bottomFound = true;
    }
}

if (!topFound) {
    // keep widget list synced with the layout.js
    let topPanel = new Panel("org.kde.plasma.mobile.panel")
    topPanel.addWidget("org.kde.plasma.notifications");
    topPanel.location = "top";
    topPanel.height = 1.25 * gridUnit;
}
if (!bottomFound) {
    let bottomPanel = new Panel("org.kde.plasma.mobile.taskpanel")
    bottomPanel.location = "bottom";
    bottomPanel.height = 2 * gridUnit;
}
