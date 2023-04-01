// SPDX-FileCopyrightText: 2017 Martin Kacej <m.kacej@atlas.sk>
// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15 as Controls

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.networkmanagement 0.2 as PlasmaNM
import org.kde.kirigami 2.2 as Kirigami
import org.kde.kirigamiaddons.labs.mobileform 0.1 as MobileForm

MobileForm.AbstractFormDelegate {
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

        Item {
            Layout.preferredWidth: Kirigami.Units.gridUnit
            Layout.preferredHeight: Kirigami.Units.gridUnit

            PlasmaCore.SvgItem {
                id: connectionSvgIcon
                elementId: mobileProxyModel.showSavedMode ? "network-wireless-connected-100" : ConnectionIcon

                svg: PlasmaCore.Svg {
                    multipleImages: true
                    imagePath: "icons/network"
                    colorGroup: PlasmaCore.ColorScope.colorGroup
                }
            }

            Controls.BusyIndicator {
                id: connectingIndicator

                anchors {
                    horizontalCenter: connectionSvgIcon.horizontalCenter
                    verticalCenter: connectionSvgIcon.verticalCenter
                }
                running: ConnectionState == PlasmaNM.Enums.Activating
                visible: running
            }
        }

        Controls.Label {
            id: connectionNameLabel

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
