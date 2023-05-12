// SPDX-FileCopyrightText: 2017 Martin Kacej <m.kacej@atlas.sk>
// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kirigamiaddons.labs.mobileform 0.1 as MobileForm
import org.kde.plasma.networkmanagement 0.2 as PlasmaNM
import org.kde.plasma.mobileinitialstart.wifi 1.0 as WiFi

Item {
    id: root
    property string name: i18n("Network")

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
        anchors.fill: parent
        anchors.topMargin: Kirigami.Units.gridUnit
        anchors.bottomMargin: Kirigami.Units.largeSpacing
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

        MobileForm.FormCard {
            maximumWidth: root.cardWidth

            Layout.fillHeight: true
            Layout.alignment: Qt.AlignTop | Qt.AlignHCenter
            Layout.fillWidth: true

            contentItem: ColumnLayout {
                spacing: 0

                ListView {
                    id: listView
                    currentIndex: -1
                    clip: true
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    section.property: "Section"
                    section.delegate: Kirigami.ListSectionHeader {
                        text: section
                    }

                    model: mobileProxyModel

                    Kirigami.PlaceholderMessage {
                        anchors.centerIn: parent
                        width: parent.width - (Kirigami.Units.largeSpacing * 4)
                        visible: !enabledConnections.wirelessEnabled
                        text: i18n("Wi-Fi is disabled")
                        icon.name: "network-wireless-disconnected"
                        helpfulAction: Kirigami.Action {
                            icon.name: "network-wireless-connected"
                            text: i18n("Enable")
                            onTriggered: handler.enableWireless(true)
                        }
                    }

                    delegate: ConnectionItemDelegate {
                        width: listView.width
                    }
                }
            }
        }
    }
}


