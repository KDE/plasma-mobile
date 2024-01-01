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

FormCard.FormCardPage {
    id: root

    property string currentWallpaperPlugin
    property string currentWallpaperPluginSource
    property var wallpaperPluginConfig

    topPadding: Kirigami.Units.gridUnit
    bottomPadding: Kirigami.Units.gridUnit
    leftPadding: 0
    rightPadding: 0

    signal requestSave()
    signal requestChangeWallpaperPlugin(string name)

    actions: [
        Kirigami.Action {
            text: i18n("Save")
            icon.name: 'document-save'
            onTriggered: root.requestSave()
        }
    ]

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

                property string selectedWallpaperPlugin: root.currentWallpaperPlugin

                onCurrentIndexChanged: {
                    var model = WallpaperImagePlugin.WallpaperPlugin.wallpaperPluginModel.get(currentIndex);
                    selectedWallpaperPlugin = model.pluginName;
                }

                function determineCurrentIndex() {
                    for (var i = 0; i < WallpaperImagePlugin.WallpaperPlugin.wallpaperPluginModel.count; ++i) {
                        var data = WallpaperImagePlugin.WallpaperPlugin.wallpaperPluginModel.get(i);
                        if (selectedWallpaperPlugin === data.pluginName) {
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

        QQC2.Button {
            id: changeWallpaperPluginButton
            Layout.alignment: Qt.AlignCenter
            text: i18n("Apply Now")
            visible: wallpaperPluginSelectComboBox.selectedWallpaperPlugin !== root.currentWallpaperPlugin 
            onClicked: root.requestChangeWallpaperPlugin(wallpaperPluginSelectComboBox.selectedWallpaperPlugin)
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
            visible: !changeWallpaperPluginButton.visible
            // visible: WallpaperImagePlugin.WallpaperPlugin.homescreenWallpaperPlugin !== "org.kde.image" // TODO
            Layout.fillWidth: true
            Layout.leftMargin: Kirigami.Units.largeSpacing
            Layout.rightMargin: Kirigami.Units.largeSpacing
            Layout.fillHeight: true
            Layout.preferredHeight: root.height - generalCard.height - 70

            wallpaperPlugin: root.currentWallpaperPlugin
            wallpaperPluginSource: root.currentWallpaperPluginSource
            wallpaperPluginConfig: root.wallpaperPluginConfig
            wallpaperPluginModel: WallpaperImagePlugin.WallpaperPlugin.wallpaperPluginModel
        }
    }
}
