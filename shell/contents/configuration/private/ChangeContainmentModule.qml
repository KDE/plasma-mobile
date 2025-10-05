// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts

import org.kde.plasma.configuration
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami
import org.kde.kirigamiaddons.formcard as FormCard

ColumnLayout {
    id: root

    property string containmentPlugin: configDialog.containmentPlugin
    signal configurationChanged // No need to emit, because containment changes apply immediately

//BEGIN functions
    function saveConfig() {
        configDialog.containmentPlugin = root.containmentPlugin
    }
//END functions

    FormCard.FormHeader {
        title: i18n("Select Homescreen")
    }

    FormCard.FormCard {
        Repeater {
            model: configDialog.containmentPluginsConfigModel
            delegate: FormCard.FormRadioDelegate {
                enabled: !Plasmoid.immutable
                text: model.name
                checked: configDialog.containmentPlugin === model.pluginName

                // Always restore binding
                onCheckedChanged: checked = Qt.binding(() => configDialog.containmentPlugin === model.pluginName);

                onClicked: {
                    if (root.containmentPlugin === model.pluginName) {
                        return;
                    }
                    root.containmentPlugin = model.pluginName;
                    confirmationDialog.name = model.name;
                    confirmationDialog.open();
                }
            }
        }
    }

    Kirigami.PromptDialog {
        id: confirmationDialog
        standardButtons: Kirigami.Dialog.Ok | Kirigami.Dialog.Cancel

        property string name

        title: i18n("Change homescreen to %1?", name)
        subtitle: i18n("Your current homescreen's settings are saved, and will be restored if you switch back.")

        onAccepted: {
            root.saveConfig();
            close();
        }
        onRejected: {
            root.containmentPlugin = configDialog.containmentPlugin;
        }
    }

    Item { Layout.fillHeight: true }
}

