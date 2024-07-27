// SPDX-FileCopyrightText: 2013 Marco Martin <mart@kde.org>
// SPDX-FileCopyrightText: 2014 Kai Uwe Broulik <kde@privat.broulik.de>
// SPDX-FileCopyrightText: 2019 David Redondo <kde@david-redondo.de>
// SPDX-FileCopyrightText: 2023 Méven Car <meven@kde.org>
// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick
import QtQuick.Controls as QQC2
import org.kde.plasma.private.mobileshell.wallpaperimageplugin as WallpaperImagePlugin

QQC2.StackView {
    id: root

    property string wallpaperPlugin
    property string wallpaperPluginSource
    property var wallpaperPluginConfig
    property var wallpaperPluginModel

    property var configDialog: QtObject {
        property string currentWallpaper: root.wallpaperPlugin
    }

    function onConfigurationChanged() {
        for (var key in root.wallpaperPluginConfig) {
            const cfgKey = "cfg_" + key;
            if (root.currentItem[cfgKey] !== undefined) {
                root.wallpaperPluginConfig[key] = root.currentItem[cfgKey]
            }
        }
    }

    onWallpaperPluginSourceChanged: {
        loadSourceFile();
    }

    onWallpaperPluginConfigChanged: {
        onWallpaperConfigurationChanged();
    }

    function onWallpaperConfigurationChanged() {
        let wallpaperConfig = root.wallpaperPluginConfig
        if (!wallpaperConfig || !root.currentItem) {
            return;
        }
        wallpaperConfig.keys().forEach(key => {
            const cfgKey = "cfg_" + key;
            if (cfgKey in root.currentItem) {

                var changedSignal = root.currentItem[cfgKey + "Changed"]
                if (changedSignal) {
                    changedSignal.disconnect(root.onConfigurationChanged);
                }
                root.currentItem[cfgKey] = wallpaperConfig[key];

                changedSignal = root.currentItem[cfgKey + "Changed"]
                if (changedSignal) {
                    changedSignal.connect(root.onConfigurationChanged)
                }
            }
        })
    }

    function loadSourceFile() {
        let wallpaperConfig = root.wallpaperPluginConfig;
        let wallpaperPluginSource = root.wallpaperPluginSource;

        // BUG 407619: wallpaperConfig can be null before calling `ContainmentItem::loadWallpaper()`
        if (wallpaperConfig && wallpaperPluginSource) {
            var props = {
                "configDialog": root.configDialog,
                "wallpaperConfiguration": wallpaperConfig
            };

            wallpaperConfig.keys().forEach(key => {
                // Preview is not part of the config, only of the WallpaperObject
                if (!key.startsWith("Preview")) {
                    props["cfg_" + key] = wallpaperConfig[key];
                }
            });

            var newItem = replace(Qt.resolvedUrl(wallpaperPluginSource), props)

            wallpaperConfig.keys().forEach(key => {
                const cfgKey = "cfg_" + key;
                if (cfgKey in root.currentItem) {
                    var changedSignal = root.currentItem[cfgKey + "Changed"]
                    if (changedSignal) {
                        changedSignal.connect(root.onConfigurationChanged)
                    }
                }
            });

            const configurationChangedSignal = newItem.configurationChanged
            if (configurationChangedSignal) {
                configurationChangedSignal.connect(root.onConfigurationChanged)
            }
        } else {
            replace(emptyConfig)
        }
    }

    Item {
        id: emptyConfig
    }
}
