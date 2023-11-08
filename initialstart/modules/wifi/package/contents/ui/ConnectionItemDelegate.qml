// SPDX-FileCopyrightText: 2017 Martin Kacej <m.kacej@atlas.sk>
// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15 as Controls

import org.kde.plasma.networkmanagement as PlasmaNM
import org.kde.kirigami 2.2 as Kirigami
import org.kde.kirigamiaddons.formcard 1.0 as FormCard
import org.kde.ksvg 1.0 as KSvg

FormCard.AbstractFormDelegate {
    topPadding: Kirigami.Units.smallSpacing
    bottomPadding: Kirigami.Units.smallSpacing

    property var map : []
    property bool predictableWirelessPassword: !Uuid && Type == PlasmaNM.Enums.Wireless &&
                                                    (SecurityType == PlasmaNM.Enums.StaticWep ||
                                                     SecurityType == PlasmaNM.Enums.WpaPsk ||
                                                     SecurityType == PlasmaNM.Enums.Wpa2Psk ||
                                                     SecurityType == PlasmaNM.Enums.SAE)

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

    contentItem: RowLayout {
        spacing: Kirigami.Units.largeSpacing

        Kirigami.Icon {
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredWidth: Kirigami.Units.iconSizes.medium
            Layout.preferredHeight: Kirigami.Units.iconSizes.medium

            source: mobileProxyModel.showSavedMode ? "network-wireless-connected-100" : ConnectionIcon

            Controls.BusyIndicator {
                anchors.fill: parent
                running: ConnectionState == PlasmaNM.Enums.Activating
            }
        }

        Controls.Label {
            Layout.fillWidth: true
            elide: Text.ElideRight
            text: ItemUniqueName
            textFormat: Text.PlainText
        }

        Controls.ToolButton {
            icon.name: "network-connect"
            visible: ConnectionState != PlasmaNM.Enums.Activated
            onClicked: changeState()
        }

        Controls.ToolButton {
            icon.name: "network-disconnect"
            visible: ConnectionState == PlasmaNM.Enums.Activated
            onClicked: handler.deactivateConnection(ConnectionPath, DevicePath)
        }
    }
}
