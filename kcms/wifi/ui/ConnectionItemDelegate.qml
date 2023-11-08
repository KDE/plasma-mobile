/*
    SPDX-FileCopyrightText: 2017 Martin Kacej <m.kacej@atlas.sk>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick 2.6
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.2 as Controls
import org.kde.plasma.networkmanagement as PlasmaNM
import org.kde.kirigami 2.2 as Kirigami
import org.kde.ksvg 1.0 as KSvg

Kirigami.SwipeListItem {

    enabled: true

    property var map : []
    property bool predictableWirelessPassword: !Uuid && Type == PlasmaNM.Enums.Wireless &&
                                                    (SecurityType == PlasmaNM.Enums.StaticWep ||
                                                     SecurityType == PlasmaNM.Enums.WpaPsk ||
                                                     SecurityType == PlasmaNM.Enums.Wpa2Psk ||
                                                     SecurityType == PlasmaNM.Enums.SAE)

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
    }

    actions: [
        Kirigami.Action {
            icon.name: "network-connect"
            visible: ConnectionState != PlasmaNM.Enums.Activated
            onTriggered: changeState()
        },
        Kirigami.Action {
            icon.name: "network-disconnect"
            visible: ConnectionState == PlasmaNM.Enums.Activated
            onTriggered: handler.deactivateConnection(ConnectionPath, DevicePath)
        },
        Kirigami.Action {
            icon.name: "configure"
            visible: (Uuid != "")? true : false
            onTriggered: {
                kcm.push("NetworkSettings.qml", {path: ConnectionPath})
            }
        },
        Kirigami.Action {
            icon.name: "entry-delete"
            visible: (Uuid != "")? true : false
            onTriggered: handler.removeConnection(ConnectionPath)
        }
    ]

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
