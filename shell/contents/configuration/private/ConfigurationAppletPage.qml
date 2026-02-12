// SPDX-FileCopyrightText: 2020 Nicolas Fella <nicolas.fella@gmx.de>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick 2.0

import org.kde.plasma.plasmoid
import org.kde.kirigami 2.10 as Kirigami

Kirigami.Page {
    id: root

    required property var configItem

    signal settingValueChanged()
    onSettingValueChanged: saveConfig() // we save config immediately on mobile

    title: configItem.name

    topPadding: 0
    leftPadding: 0
    rightPadding: 0
    bottomPadding: 0

    function saveConfig() {
        for (let key in Plasmoid.configuration) {
            if (loader.item["cfg_" + key] != undefined) {
                Plasmoid.configuration[key] = loader.item["cfg_" + key]
            }
        }

        // For ConfigurationContainmentActions.qml
        if (loader.item.hasOwnProperty("saveConfig")) {
            loader.item.saveConfig()
        }
    }

    data: [
        Loader {
            id: loader

            Component.onCompleted: {
                const plasmoidConfig = Plasmoid.configuration

                const props = {}
                for (let key in plasmoidConfig) {
                    props["cfg_" + key] = Plasmoid.configuration[key]
                }

                // Inject configurable config values
                setSource(configItem.source, props)
            }

            onLoaded: {
                item.parent = root.contentItem;
                item.anchors.fill = root.contentItem;

                const plasmoidConfig = Plasmoid.configuration;

                for (let key in plasmoidConfig) {
                    const changedSignal = item["cfg_" + key + "Changed"]
                    if (changedSignal) {
                        changedSignal.connect(root.settingValueChanged)
                    }
                }

                const configurationChangedSignal = item.configurationChanged
                if (configurationChangedSignal) {
                    configurationChangedSignal.connect(root.settingValueChanged)
                }

                var unsavedChangesChangedSignal = item.unsavedChangesChanged
                if (unsavedChangesChangedSignal) {
                    unsavedChangesChangedSignal.connect( () => {
                        if (item.unsavedChanges) {
                            root.settingValueChanged()
                        }
                    })
                }
            }
        }
    ]
}
