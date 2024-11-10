// SPDX-FileCopyrightText: 2017 Martin Kacej <m.kacej@atlas.sk>
// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import org.kde.kirigami 2.20 as Kirigami
import org.kde.kirigamiaddons.formcard 1.0 as FormCard
import org.kde.plasma.networkmanagement as PlasmaNM
import org.kde.plasma.mobileinitialstart.wifi 1.0 as WiFi

import org.kde.plasma.mobileinitialstart.initialstart

InitialStartModule {
    name: i18n("Network")
    contentItem: Item {
        id: root

        readonly property real cardWidth: Math.min(Kirigami.Units.gridUnit * 30, root.width - Kirigami.Units.gridUnit * 2)

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

        ConnectDialog {
            id: connectionDialog
        }

        Component.onCompleted: handler.requestScan()

        Timer {
            id: scanTimer
            interval: 10200
            repeat: true
            running: parent.visible

            onTriggered: handler.requestScan()
        }

        ColumnLayout {
            anchors {
                fill: parent
                topMargin: Kirigami.Units.gridUnit
                bottomMargin: Kirigami.Units.largeSpacing
            }

            width: root.width
            spacing: Kirigami.Units.gridUnit

            Label {
                Layout.leftMargin: Kirigami.Units.gridUnit
                Layout.rightMargin: Kirigami.Units.gridUnit
                Layout.alignment: Qt.AlignTop
                Layout.fillWidth: true

                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
                text: i18n("Connect to a WiFi network for network access.")
            }

            FormCard.FormCard {
                id: savedCard
                maximumWidth: root.cardWidth
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
                        editMode: false

                        // connected or saved
                        property bool shouldDisplay: (Uuid != "") || ConnectionState === PlasmaNM.Enums.Activated
                        onShouldDisplayChanged: savedCard.updateCount()

                        // separate property for visible since visible is false when the whole card is not visible
                        visible: (Uuid != "") || ConnectionState === PlasmaNM.Enums.Activated
                    }
                }
            }

            FormCard.FormCard {
                Layout.fillHeight: true
                maximumWidth: root.cardWidth
                visible: enabledConnections.wirelessEnabled

                ListView {
                    id: listView

                    clip: true
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    model: mobileProxyModel

                    delegate: ConnectionItemDelegate {
                        width: ListView.view.width
                        editMode: false
                        height: visible ? implicitHeight : 0
                        visible: !((Uuid != "") || ConnectionState === PlasmaNM.Enums.Activated)
                    }
                }
            }
        }
    }
}