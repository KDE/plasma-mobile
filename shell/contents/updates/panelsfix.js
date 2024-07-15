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
    loadTemplate("org.kde.plasma.mobile.defaultStatusBar");
}
if (!bottomFound) {
    loadTemplate("org.kde.plasma.mobile.defaultNavigationPanel");
}
