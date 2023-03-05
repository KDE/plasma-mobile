// SPDX-FileCopyrightText: 2014 Aaron J. Seigo
// SPDX-FileCopyrightText: 2014-2019 Marco Martin <mart@kde.org>
// SPDX-FileCopyrightText: 2015-2021 Bhushan Shah <bshah@kde.org>
// SPDX-FileCopyrightText: 2021 Aleix Pol <apol@kde.org>
// SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

var desktopsArray = desktopsForActivity(currentActivity());
for (var j = 0; j < desktopsArray.length; j++) {
    desktopsArray[j].wallpaperPlugin = "org.kde.image";

    if (j == 0) {
        // add meta shortcut
        desktopsArray[0].currentConfigGroup = ["Shortcuts"]
        desktopsArray[0].writeConfig("global", "Meta+F1")
    }
}

// keep this list in sync with shell/contents/updates/panelsfix.js
var panel = new Panel("org.kde.plasma.mobile.panel");
panel.location = "top";
panel.addWidget("org.kde.plasma.notifications");
panel.height = 1.25 * gridUnit; // HACK: supposed to be gridUnit + smallSpacing, but it doesn't seem to give the correct number

var bottomPanel = new Panel("org.kde.plasma.mobile.taskpanel")
bottomPanel.location = "bottom";
bottomPanel.height = 2 * gridUnit;
