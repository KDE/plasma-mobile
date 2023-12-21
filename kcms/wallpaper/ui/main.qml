// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2

import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import org.kde.kirigamiaddons.formcard 1.0 as FormCard
import org.kde.plasma.private.mobileshell.shellsettingsplugin as ShellSettings
import org.kde.plasma.private.mobileshell.wallpaperimageplugin as WallpaperImagePlugin
import org.kde.newstuff as NewStuff

KCM.SimpleKCM {
    id: root

    title: i18n("Wallpaper")

    topPadding: Kirigami.Units.gridUnit
    bottomPadding: Kirigami.Units.gridUnit
    leftPadding: 0
    rightPadding: 0

    ColumnLayout {

        FormCard.FormCard {
            id: generalCard

            FormCard.FormComboBoxDelegate {
                id: wallpaperPluginSelectComboBox
                text: i18nd("plasma_shell_org.kde.plasma.desktop", "Wallpaper Plugin")
                description: i18n("The wallpaper plugin to use.")

                model: WallpaperImagePlugin.WallpaperPlugin.wallpaperPluginModel
                textRole: "name"
                valueRole: "pluginName"
                currentIndex: determineCurrentIndex()

                property string currentWallpaperPlugin: WallpaperImagePlugin.WallpaperPlugin.homescreenWallpaperPlugin

                onCurrentIndexChanged: {
                    var model = WallpaperImagePlugin.WallpaperPlugin.wallpaperPluginModel.get(currentIndex);
                    currentWallpaperPlugin = model.pluginName;
                }

                function determineCurrentIndex() {
                    for (var i = 0; i < WallpaperImagePlugin.WallpaperPlugin.wallpaperPluginModel.count; ++i) {
                        var data = WallpaperImagePlugin.WallpaperPlugin.wallpaperPluginModel.get(i);
                        if (currentWallpaperPlugin === data.pluginName) {
                            return i;
                        }
                    }
                    return -1;
                }
            }

            FormCard.FormDelegateSeparator { above: wallpaperPluginSelectComboBox }

            FormCard.FormTextDelegate {
                text: i18n("Get a new wallpaper plugin")
                trailing: NewStuff.Button {
                    configFile: "wallpaperplugin.knsrc"
                    text: i18n("Get New Plugins…")
                    visibleWhenDisabled: true // don't hide on disabled
                }
            }
        }

        // FormCard.FormHeader {
        //     visible: WallpaperImagePlugin.WallpaperPlugin.homescreenWallpaperPlugin === "org.kde.image" // TODO
        //     title: i18n("Wallpaper Selector")
        // }

        // FormCard.FormCard {
        //     visible: WallpaperImagePlugin.WallpaperPlugin.homescreenWallpaperPlugin === "org.kde.image"// TODO
        // }

        WallpaperImagePlugin.WallpaperPluginConfigLoader {
            id: wallpaperPluginConfig
            // visible: WallpaperImagePlugin.WallpaperPlugin.homescreenWallpaperPlugin !== "org.kde.image" // TODO
            Layout.fillWidth: true
            Layout.leftMargin: Kirigami.Units.largeSpacing
            Layout.rightMargin: Kirigami.Units.largeSpacing
            Layout.fillHeight: true
            Layout.preferredHeight: root.height - generalCard.height - 70

            wallpaperPlugin: WallpaperImagePlugin.WallpaperPlugin.homescreenWallpaperPlugin
            wallpaperPluginSource: WallpaperImagePlugin.WallpaperPlugin.homescreenWallpaperPluginSource
            wallpaperPluginConfig: WallpaperImagePlugin.WallpaperPlugin.homescreenConfiguration
            wallpaperPluginModel: WallpaperImagePlugin.WallpaperPlugin.wallpaperPluginModel
        }
    }
}
