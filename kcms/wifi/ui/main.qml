// SPDX-FileCopyrightText: 2017 Martin Kacej <m.kacej@atlas.sk>
// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls

import org.kde.plasma.networkmanagement as PlasmaNM
import org.kde.kirigami as Kirigami
import org.kde.kcmutils
import org.kde.kirigamiaddons.formcard 1 as FormCard

SimpleKCM {
    id: root

    property bool editMode: false

    topPadding: Kirigami.Units.gridUnit
    bottomPadding: Kirigami.Units.gridUnit
    leftPadding: 0
    rightPadding: 0

    actions: [
        Kirigami.Action {
            text: i18n("Edit")
            icon.name: 'entry-edit'
            checkable: true
            onCheckedChanged: root.editMode = checked
        }
    ]

    PlasmaNM.Handler {
        id: handler
    }

    PlasmaNM.EnabledConnections {
        id: enabledConnections
    }

    PlasmaNM.NetworkModel {
        id: connectionModel
    }

    PlasmaNM.MobileProxyModel {
        id: mobileProxyModel
        sourceModel: connectionModel
        showSavedMode: false
    }

    Component.onCompleted: handler.requestScan()

    Timer {
        id: scanTimer
        interval: 10200
        repeat: true
        running: parent.visible

        onTriggered: handler.requestScan()
    }

    ConnectDialog {
        id: connectionDialog
        parent: root
    }

    ColumnLayout {

        Kirigami.InlineMessage {
            id: inlineError
            showCloseButton: true
            Layout.fillWidth: true

            type: Kirigami.MessageType.Warning
            Connections {
                target: handler
                function onConnectionActivationFailed(connectionPath, message) {
                    inlineError.text = message;
                    inlineError.visible = true;
                }
            }
        }

        FormCard.FormCard {
            FormCard.FormSwitchDelegate {
                id: wifiSwitch
                text: i18n("Wi-Fi")
                checked: enabledConnections.wirelessEnabled
                onCheckedChanged: {
                    handler.enableWireless(checked);
                    checked = Qt.binding(() => enabledConnections.wirelessEnabled);
                }
            }
        }

        FormCard.FormHeader {
            visible: savedCard.visible
            title: i18nc("@title:group", "Saved Networks")
        }

        FormCard.FormCard {
            id: savedCard
            visible: enabledConnections.wirelessEnabled && count > 0

            // number of visible entries
            property int count: 0
            function updateCount() {
                count = 0;
                for (let i = 0; i < connectedRepeater.count; i++) {
                    let item = connectedRepeater.itemAt(i);
                    if (item && item.shouldDisplay) {
                        count++;
                    }
                }
            }

            Repeater {
                id: connectedRepeater
                model: mobileProxyModel
                delegate: ConnectionItemDelegate {
                    editMode: root.editMode

                    // connected or saved
                    property bool shouldDisplay: (Uuid != "") || ConnectionState === PlasmaNM.Enums.Activated
                    onShouldDisplayChanged: savedCard.updateCount()

                    // separate property for visible since visible is false when the whole card is not visible
                    visible: shouldDisplay
                }
            }
        }

        FormCard.FormHeader {
            visible: enabledConnections.wirelessEnabled
            title: i18n("Available Networks")
        }

        FormCard.FormCard {
            id: availableCard
            visible: enabledConnections.wirelessEnabled && count > 0

            // number of visible entries
            property int count: 0
            function updateCount() {
                count = 0;
                for (let i = 0; i < availableRepeater.count; i++) {
                    let item = availableRepeater.itemAt(i);
                    if (item && item.shouldDisplay) {
                        count++;
                    }
                }
            }

            Repeater {
                id: availableRepeater
                model: mobileProxyModel
                delegate: ConnectionItemDelegate {
                    editMode: root.editMode

                    property bool shouldDisplay: !((Uuid != "") || ConnectionState === PlasmaNM.Enums.Activated)
                    onShouldDisplayChanged: availableCard.updateCount()

                    visible: shouldDisplay
                }
            }

            FormCard.FormButtonDelegate {
                icon.name: 'list-add'
                text: i18n("Add Custom Connection")
                visible: enabledConnections.wirelessEnabled
                onClicked: kcm.push("NetworkSettings.qml")
            }
        }
    }
}
