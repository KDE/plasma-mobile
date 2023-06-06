/*
    SPDX-FileCopyrightText: 2017 Martin Kacej <m.kacej@atlas.sk>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick 2.6
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.2 as Controls
import org.kde.plasma.networkmanagement 0.2 as PlasmaNM
import org.kde.kirigami 2.12 as Kirigami
import org.kde.kcmutils

ScrollViewKCM {
    id: main

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

    header: Kirigami.InlineMessage {
        id: inlineError
        showCloseButton: true

        type: Kirigami.MessageType.Warning
        Connections {
            target: handler
            function onConnectionActivationFailed(connectionPath, message) {
                inlineError.text = message;
                inlineError.visible = true;
            }
        }
    }

    ConnectDialog {
        id: connectionDialog
    }
    
    view: ListView {
        id: view

        clip: true
        currentIndex: -1

        section.property: "Section"
        section.delegate: Kirigami.ListSectionHeader {
            text: section
        }

        model: mobileProxyModel
        delegate: ConnectionItemDelegate {}

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
    }

    footer: Kirigami.ActionToolBar {
        flat: false
        actions: [
            Kirigami.Action {
                text: i18n("Disable Wi-Fi")
                icon.name: "network-disconnect"
                visible: enabledConnections.wirelessEnabled
                onTriggered: handler.enableWireless(false)
            },
            Kirigami.Action {
                text: i18n("Add Custom Connection")
                icon.name: "list-add"
                visible: enabledConnections.wirelessEnabled
                onTriggered: kcm.push("NetworkSettings.qml")
            },
            Kirigami.Action {
                text: i18n("Show Saved Connections")
                icon.name: "document-save"
                onTriggered: mobileProxyModel.showSavedMode = !mobileProxyModel.showSavedMode
                checkable: true
                checked: false
                visible: enabledConnections.wirelessEnabled
            }
        ]
    }
}
