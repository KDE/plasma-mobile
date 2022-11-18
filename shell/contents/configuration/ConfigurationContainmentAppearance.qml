/*
 *  SPDX-FileCopyrightText: 2013 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.15
import org.kde.plasma.configuration 2.0
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.15

import org.kde.newstuff 1.62 as NewStuff
import org.kde.kirigami 2.19 as Kirigami
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kirigamiaddons.labs.mobileform 0.1 as MobileForm

ColumnLayout {
    id: root
    spacing: 0

    property string currentWallpaper: ""
    property string containmentPlugin: configDialog.containmentPlugin
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

    Kirigami.InlineMessage {
        Layout.alignment: Qt.AlignTop
        visible: plasmoid.immutable || animating
        text: i18nd("plasma_shell_org.kde.plasma.desktop", "Layout changes have been restricted by the system administrator")
        showCloseButton: true
        Layout.fillWidth: true
        Layout.leftMargin: Kirigami.Units.smallSpacing
        Layout.rightMargin: Kirigami.Units.smallSpacing
        Layout.bottomMargin: Kirigami.Units.smallSpacing * 2 // we need this because ColumnLayout's spacing is 0
    }

    ColumnLayout {
        id: generalConfig
        spacing: 0
        Layout.alignment: Qt.AlignTop
        Layout.fillWidth: true
        
        MobileForm.FormCard {
            Layout.fillWidth: true
            
            contentItem: ColumnLayout {
                spacing: 0
                
                MobileForm.FormCardHeader {
                    title: i18n("General")
                }
                
                MobileForm.FormComboBoxDelegate {
                    id: layoutSelectComboBox
                    enabled: !plasmoid.immutable
                    text: i18nd("plasma_shell_org.kde.plasma.desktop", "Homescreen Layout")
                    description: i18n("The homescreen layout to use.")
                    visible: model.count > 1 // only show if there are multiple plugins
                    
                    model: configDialog.containmentPluginsConfigModel
                    textRole: "name"
                    valueRole: "pluginName"
                    currentIndex: determineCurrentIndex()
                    onCurrentIndexChanged: {
                        root.containmentPlugin = configDialog.containmentPluginsConfigModel.get(currentIndex).pluginName;
                    }
                    
                    function determineCurrentIndex() {
                        for (var i = 0; i < configDialog.containmentPluginsConfigModel.count; ++i) {
                            var data = configDialog.containmentPluginsConfigModel.get(i);
                            if (configDialog.containmentPlugin === data.pluginName) {
                                return i;
                            }
                        }
                        return -1;
                    }
                }
                
                MobileForm.FormDelegateSeparator { above: layoutSelectComboBox; below: wallpaperPluginSelectComboBox }
                
                MobileForm.FormComboBoxDelegate {
                    id: wallpaperPluginSelectComboBox
                    text: i18nd("plasma_shell_org.kde.plasma.desktop", "Wallpaper Plugin")
                    description: i18n("The wallpaper plugin to use.")
                    
                    model: configDialog.wallpaperConfigModel
                    textRole: "name"
                    valueRole: "pluginName"
                    currentIndex: determineCurrentIndex()
                    onCurrentIndexChanged: {
                        var model = configDialog.wallpaperConfigModel.get(currentIndex);
                        root.currentWallpaper = model.pluginName;
                        configDialog.currentWallpaper = model.pluginName;
                        main.sourceFile = model.source;
                        root.configurationChanged();
                    }
                    
                    function determineCurrentIndex() {
                        for (var i = 0; i < configDialog.wallpaperConfigModel.count; ++i) {
                            var data = configDialog.wallpaperConfigModel.get(i);
                            if (configDialog.currentWallpaper === data.pluginName) {
                                return i;
                            }
                        }
                        return -1;
                    }
                }
                
                MobileForm.FormDelegateSeparator { above: wallpaperPluginSelectComboBox }
                
                MobileForm.AbstractFormDelegate {
                    id: wallpaperPluginButton
                    Layout.fillWidth: true
                    background: Item {}
                    
                    contentItem: RowLayout {
                        QQC2.Label {
                            Layout.fillWidth: true
                            text: i18n("Wallpaper Plugins")
                        }
                        
                        NewStuff.Button {
                            configFile: "wallpaperplugin.knsrc"
                            text: i18nd("plasma_shell_org.kde.plasma.desktop", "Get New Plugins…")
                        }
                    }
                }
            }
        }
    }

    ColumnLayout {
        id: switchContainmentWarning
        Layout.alignment: Qt.AlignTop
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
        Layout.alignment: Qt.AlignTop
        Layout.fillHeight: switchContainmentWarning.visible
        visible: switchContainmentWarning.visible
    }
    
    Item {
        id: emptyConfig
        Layout.alignment: Qt.AlignTop
    }

    QQC2.StackView {
        id: main

        Layout.alignment: Qt.AlignTop
        Layout.fillHeight: true
        Layout.maximumHeight: root.height - generalConfig.height - 70 // HACK: wallpaper configs seem to go over the provisioned height
        Layout.fillWidth: true

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

