/*
 *  SPDX-FileCopyrightText: 2013 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.15
import org.kde.plasma.configuration 2.0
import QtQuick.Controls 2.3 as QQC2
import QtQuick.Layouts 1.1

import org.kde.newstuff 1.62 as NewStuff
import org.kde.kirigami 2.5 as Kirigami
import org.kde.plasma.core 2.0 as PlasmaCore

ColumnLayout {
    id: root

    property int formAlignment: wallpaperComboBox.Kirigami.ScenePosition.x - root.Kirigami.ScenePosition.x + (PlasmaCore.Units.largeSpacing/2)
    property string currentWallpaper: ""
    property string containmentPlugin: ""
    signal configurationChanged

//BEGIN functions
    function saveConfig() {
        if (main.currentItem.saveConfig) {
            main.currentItem.saveConfig()
        }
        for (var key in configDialog.wallpaperConfiguration) {
            if (main.currentItem["cfg_"+key] !== undefined) {
                configDialog.wallpaperConfiguration[key] = main.currentItem["cfg_"+key]
            }
        }
        configDialog.currentWallpaper = root.currentWallpaper;
        configDialog.applyWallpaper()
        configDialog.containmentPlugin = root.containmentPlugin
    }
//END functions

    Component.onCompleted: {
        for (var i = 0; i < configDialog.wallpaperConfigModel.count; ++i) {
            var data = configDialog.wallpaperConfigModel.get(i);
            if (configDialog.currentWallpaper == data.pluginName) {
                wallpaperComboBox.currentIndex = i
                wallpaperComboBox.activated(i);
                break;
            }
        }
    }

    Kirigami.InlineMessage {
        visible: plasmoid.immutable || animating
        text: i18nd("plasma_shell_org.kde.plasma.desktop", "Layout changes have been restricted by the system administrator")
        showCloseButton: true
        Layout.fillWidth: true
        Layout.leftMargin: Kirigami.Units.smallSpacing
        Layout.rightMargin: Kirigami.Units.smallSpacing
        Layout.bottomMargin: Kirigami.Units.smallSpacing * 2 // we need this because ColumnLayout's spacing is 0
    }

    Kirigami.FormLayout {
        Layout.fillWidth: true
        
        Component.onCompleted: {
            for (var i = 0; i < configDialog.containmentPluginsConfigModel.count; ++i) {
                var data = configDialog.containmentPluginsConfigModel.get(i);
                if (configDialog.containmentPlugin === data.pluginName) {
                    pluginComboBox.currentIndex = i
                    pluginComboBox.activated(i);
                    break;
                }
            }

            for (var i = 0; i < configDialog.wallpaperConfigModel.count; ++i) {
                var data = configDialog.wallpaperConfigModel.get(i);
                if (configDialog.currentWallpaper === data.pluginName) {
                    wallpaperComboBox.currentIndex = i
                    wallpaperComboBox.activated(i);
                    break;
                }
            }
        }
        
        QQC2.ComboBox {
            id: pluginComboBox
            Layout.preferredWidth: Math.max(implicitWidth, wallpaperComboBox.implicitWidth)
            Kirigami.FormData.label: i18nd("plasma_shell_org.kde.plasma.desktop", "Layout:")
            enabled: !plasmoid.immutable
            model: configDialog.containmentPluginsConfigModel
            textRole: "name"
            visible: count > 1 // only show if there are multiple plugins
            onActivated: {
                var model = configDialog.containmentPluginsConfigModel.get(currentIndex)
                root.containmentPlugin = model.pluginName
                root.settingValueChanged()
            }
        }
        
        RowLayout {
            Layout.fillWidth: true
            Kirigami.FormData.label: i18nd("plasma_shell_org.kde.plasma.desktop", "Wallpaper Type:")
            QQC2.ComboBox {
                id: wallpaperComboBox
                Layout.preferredWidth: Math.max(implicitWidth, pluginComboBox.implicitWidth)
                model: configDialog.wallpaperConfigModel
                width: PlasmaCore.Theme.mSize(PlasmaCore.Theme.defaultFont).width * 24
                textRole: "name"
                onActivated: {
                    var model = configDialog.wallpaperConfigModel.get(currentIndex)
                    root.currentWallpaper = model.pluginName
                    configDialog.currentWallpaper = model.pluginName
                    main.sourceFile = model.source
                    root.configurationChanged()
                }
            }
            NewStuff.Button {
                configFile: "wallpaperplugin.knsrc"
                text: i18nd("plasma_shell_org.kde.plasma.desktop", "Get New Plugins…")
                Layout.preferredHeight: wallpaperComboBox.height
            }
        }
    }

    ColumnLayout {
        id: switchContainmentWarning
        Layout.fillWidth: true
        visible: configDialog.containmentPlugin !== root.containmentPlugin
        QQC2.Label {
            Layout.fillWidth: true
            text: i18nd("plasma_shell_org.kde.plasma.desktop", "Layout changes must be applied before other changes can be made")
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
        }
        QQC2.Button {
            Layout.alignment: Qt.AlignHCenter
            text: i18nd("plasma_shell_org.kde.plasma.desktop", "Apply now")
            onClicked: saveConfig()
        }
    }

    Item {
        Layout.fillHeight: true
        visible: switchContainmentWarning.visible
    }
    
    Item {
        id: emptyConfig
    }

    QQC2.StackView {
        id: main

        Layout.fillHeight: true;
        Layout.fillWidth: true;

        visible: !switchContainmentWarning.visible
        
        // Bug 360862: if wallpaper has no config, sourceFile will be ""
        // so we wouldn't load emptyConfig and break all over the place
        // hence set it to some random value initially
        property string sourceFile: "tbd"
        onSourceFileChanged: {
            if (sourceFile) {
                var props = {}

                var wallpaperConfig = configDialog.wallpaperConfiguration
                for (var key in wallpaperConfig) {
                    props["cfg_" + key] = wallpaperConfig[key]
                }

                var newItem = replace(Qt.resolvedUrl(sourceFile), props)

                for (var key in wallpaperConfig) {
                    var changedSignal = newItem["cfg_" + key + "Changed"]
                    if (changedSignal) {
                        changedSignal.connect(root.configurationChanged)
                    }
                }
            } else {
                replace(emptyConfig)
            }
        }
    }
}

