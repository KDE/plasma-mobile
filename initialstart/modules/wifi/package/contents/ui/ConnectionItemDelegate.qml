// SPDX-FileCopyrightText: 2017 Martin Kacej <m.kacej@atlas.sk>
// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.Controls as Controls

import org.kde.plasma.networkmanagement as PlasmaNM
import org.kde.kirigami as Kirigami
import org.kde.ksvg as KSvg
import org.kde.kirigamiaddons.formcard 1 as FormCard

FormCard.AbstractFormDelegate {
    id: root

    property bool editMode
    property var map : []
    property bool predictableWirelessPassword: !Uuid && Type == PlasmaNM.Enums.Wireless &&
                                                    (SecurityType == PlasmaNM.Enums.StaticWep ||
                                                     SecurityType == PlasmaNM.Enums.WpaPsk ||
                                                     SecurityType == PlasmaNM.Enums.Wpa2Psk ||
                                                     SecurityType == PlasmaNM.Enums.SAE)

    verticalPadding: Kirigami.Units.largeSpacing

    contentItem: RowLayout {
        spacing: 0

        Item {
            Layout.rightMargin: Kirigami.Units.gridUnit
            implicitWidth: Kirigami.Units.iconSizes.smallMedium
            implicitHeight: Kirigami.Units.iconSizes.smallMedium

            Kirigami.Icon {
                implicitWidth: Kirigami.Units.iconSizes.smallMedium
                implicitHeight: Kirigami.Units.iconSizes.smallMedium
                visible: ConnectionState !== PlasmaNM.Enums.Activating
                anchors.centerIn: parent
                source: mobileProxyModel.showSavedMode ? "network-wireless-connected-100" : ConnectionIcon
            }

            Controls.BusyIndicator {
                anchors.fill: parent
                running: ConnectionState === PlasmaNM.Enums.Activating
            }
        }

        Controls.Label {
            id: internalTextItem
            Layout.fillWidth: true
            text: ItemUniqueName
            elide: Text.ElideRight
            font.bold: ConnectionState === PlasmaNM.Enums.Activated
            Accessible.ignored: true // base class sets this text on root already
        }

        RowLayout {
            Kirigami.Icon {
                Layout.alignment: Qt.AlignVCenter
                Layout.preferredWidth: Kirigami.Units.iconSizes.smallMedium
                Layout.preferredHeight: Kirigami.Units.iconSizes.smallMedium
                visible: ConnectionState === PlasmaNM.Enums.Activated
                source: 'checkmark'
            }

            // ensure that the row is always of same height
            Controls.ToolButton {
                id: heightMetrics
                opacity: 0
                implicitWidth: 0
                icon.name: 'network-connect'
                enabled: false
            }
            Controls.ToolButton {
                icon.name: "network-connect"
                text: i18n("Connect")
                visible: ConnectionState != PlasmaNM.Enums.Activated && root.editMode
                display: Controls.ToolButton.IconOnly
                onClicked: changeState()
            }
            Controls.ToolButton {
                icon.name: "network-disconnect"
                text: i18n("Disconnect")
                visible: ConnectionState == PlasmaNM.Enums.Activated && root.editMode
                display: Controls.ToolButton.IconOnly
                onClicked: handler.deactivateConnection(ConnectionPath, DevicePath)
            }
            Controls.ToolButton {
                icon.name: "configure"
                text: i18n("Configure")
                visible: (Uuid != "") && root.editMode
                display: Controls.ToolButton.IconOnly
                onClicked: {
                    kcm.push("NetworkSettings.qml", {path: ConnectionPath})
                }
            }
            Controls.ToolButton {
                icon.name: "entry-delete"
                text: i18n("Delete")
                visible: (Uuid != "") && root.editMode
                display: Controls.ToolButton.IconOnly
                onClicked: handler.removeConnection(ConnectionPath)
            }
        }
    }

    onClicked: {
        changeState()
    }

    function changeState() {
        if (Uuid || !predictableWirelessPassword) {
            if (ConnectionState == PlasmaNM.Enums.Deactivated) {
                if (!predictableWirelessPassword && !Uuid) {
                    handler.addAndActivateConnection(DevicePath, SpecificPath);
                } else {
                    handler.activateConnection(ConnectionPath, DevicePath, SpecificPath);
                }
            } else{
                //show popup
            }
        } else if (predictableWirelessPassword) {
            connectionDialog.headingText = i18n("Connect to") + " " + ItemUniqueName;
            connectionDialog.devicePath = DevicePath;
            connectionDialog.specificPath = SpecificPath;
            connectionDialog.securityType = SecurityType;
            connectionDialog.openAndClear();
        }
    }
}
