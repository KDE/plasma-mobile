/*
    SPDX-FileCopyrightText: 2017 Martin Kacej <m.kacej@atlas.sk>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick 2.6
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.2 as Controls
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.networkmanagement 0.2 as PlasmaNM
import org.kde.kirigami 2.2 as Kirigami

Kirigami.SwipeListItem {

    enabled: true

    property var map : []
    property bool predictableWirelessPassword: !Uuid && Type == PlasmaNM.Enums.Wireless &&
                                                    (SecurityType == PlasmaNM.Enums.StaticWep ||
                                                     SecurityType == PlasmaNM.Enums.WpaPsk ||
                                                     SecurityType == PlasmaNM.Enums.Wpa2Psk ||
                                                     SecurityType == PlasmaNM.Enums.SAE)

    RowLayout {
        anchors.leftMargin: Kirigami.Units.largeSpacing * 5
        spacing: Kirigami.Units.largeSpacing
        Kirigami.Separator {}

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
    }

    actions: [
        Kirigami.Action {
            iconName: "network-connect"
            visible: ConnectionState != PlasmaNM.Enums.Activated
            onTriggered: changeState()
        },
        Kirigami.Action {
            iconName: "network-disconnect"
            visible: ConnectionState == PlasmaNM.Enums.Activated
            onTriggered: handler.deactivateConnection(ConnectionPath, DevicePath)
        },
        Kirigami.Action {
            iconName: "configure"
            visible: (Uuid != "")? true : false
            onTriggered: {
                kcm.push("NetworkSettings.qml", {path: ConnectionPath})
            }
        },
        Kirigami.Action {
            iconName: "entry-delete"
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
