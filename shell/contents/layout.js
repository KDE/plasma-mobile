// SPDX-FileCopyrightText: 2014 Aaron J. Seigo
// SPDX-FileCopyrightText: 2014-2019 Marco Martin <mart@kde.org>
// SPDX-FileCopyrightText: 2015-2021 Bhushan Shah <bshah@kde.org>
// SPDX-FileCopyrightText: 2021 Aleix Pol <apol@kde.org>
// SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

// Load panel layout
loadTemplate("org.kde.plasma.mobile.defaultNavigationPanel");
loadTemplate("org.kde.plasma.mobile.defaultStatusBar");

// Set wallpaper plugin
var desktopsArray = desktopsForActivity(currentActivity());
for (var j = 0; j < desktopsArray.length; j++) {
    desktopsArray[j].wallpaperPlugin = "org.kde.image";

    if (j == 0) {
        // Add meta shortcut
        desktopsArray[0].currentConfigGroup = ["Shortcuts"]
        desktopsArray[0].writeConfig("global", "Meta+F1")
    }
}
