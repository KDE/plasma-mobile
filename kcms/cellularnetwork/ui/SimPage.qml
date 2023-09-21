// SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls

import org.kde.plasma.networkmanagement as PlasmaNM
import org.kde.kcmutils
import org.kde.kirigami as Kirigami
import org.kde.kirigamiaddons.formcard 1 as FormCard
import org.kde.kirigamiaddons.components 1 as Components

import cellularnetworkkcm 1.0

FormCard.FormCardPage {
    id: simPage

    property Sim sim: null

    property string displayId: sim ? sim.displayId : ""
    property bool simEnabled: sim ? sim.enabled : false
    property bool isRoaming: sim ? (sim.modem ? sim.modem.isRoaming : false) : false

    property bool simLocked: sim ? sim.locked : false
    property string simImsi: sim ? sim.imsi : ""
    property string simEid: sim ? sim.eid : ""
    property string operatorCode: sim ? (sim.modem ? sim.modem.details.operatorCode : "") : ""
    property string operatorName: sim ? (sim.modem ? sim.modem.details.operatorName : "") : ""
    property string simOperatorIdentifier: sim ? sim.operatorIdentifier : ""
    property string simOperatorName: sim ? sim.operatorName : ""
    property string simIdentifier: sim ? sim.simIdentifier : ""
    property var simEmergencyNumbers: sim ? sim.emergencyNumbers : []

    title: i18n("SIM") + " " + displayId

    data: PlasmaNM.EnabledConnections {
        id: enabledConnections
    }

    header: Components.Banner {
        width: parent.width
        visible: !simEnabled
        type: Kirigami.MessageType.Error
        text: i18n("This SIM slot is empty, a SIM card needs to be inserted in order for it to be used.")
    }

    MessagesList {
        id: messagesList
        Layout.fillWidth: true
        Layout.margins: Kirigami.Units.gridUnit
        model: kcm.messages
    }

    FormCard.FormCard {
        FormCard.FormSwitchDelegate {
            id: dataRoamingCheckBox
            text: i18n("Data Roaming")
            description: i18n("Allow your device to use networks other than your carrier.")
            enabled: simEnabled
            checked: isRoaming
            onCheckedChanged: sim.modem.isRoaming = checked
        }

        FormCard.FormDelegateSeparator { above: dataRoamingCheckBox; below: apnButton }

        FormCard.FormButtonDelegate {
            id: apnButton
            icon.name: "globe"
            text: i18n("Modify APNs")
            description: i18n("Configure access point names for your carrier.")
            enabled: simEnabled && enabledConnections.wwanEnabled
            onClicked: kcm.push("ProfileList.qml", { "modem": sim.modem });
        }

        FormCard.FormDelegateSeparator { above: apnButton; below: networksButton }

        FormCard.FormButtonDelegate {
            id: networksButton
            icon.name: "network-mobile-available"
            text: i18n("Networks")
            description: i18n("Select a network operator.")
            enabled: simEnabled
            onClicked: kcm.push("AvailableNetworks.qml", { "modem": sim.modem, "sim": sim });
        }

        FormCard.FormDelegateSeparator { above: networksButton; below: simLockButton }

        FormCard.FormButtonDelegate {
            id: simLockButton
            icon.name: "unlock"
            text: i18n("SIM Lock")
            description: i18n("Modify SIM lock settings.")
            enabled: simEnabled
            onClicked: kcm.push("SimLockPage.qml", { "sim": sim });
        }

        FormCard.FormDelegateSeparator { above: simLockButton; below: modemDetailsButton }

        FormCard.FormButtonDelegate {
            id: modemDetailsButton
            icon.name: "network-modem"
            text: i18n("Modem Details")
            description: i18n("View the details of the modem this SIM is connected to.")
            onClicked: kcm.push("ModemPage.qml", { "modem": sim.modem })
        }
    }

    FormCard.FormHeader {
        title: i18n("SIM Details")
    }

    FormCard.FormCard {
        FormCard.FormTextDelegate {
            id: lockedText
            text: i18n("Locked")
            description: simLocked ? i18n("Yes") : i18n("No")
        }

        FormCard.FormDelegateSeparator {}

        FormCard.FormTextDelegate  {
            id: imsiText
            text: i18n("IMSI")
            description: simImsi
        }

        FormCard.FormDelegateSeparator {}

        FormCard.FormTextDelegate  {
            id: eidText
            text: i18n("EID")
            description: simEid
        }

        FormCard.FormDelegateSeparator {}

        FormCard.FormTextDelegate {
            id: opCodeModemText
            text: i18n("Operator Code (modem)")
            description: operatorCode
        }

        FormCard.FormDelegateSeparator {}

        FormCard.FormTextDelegate  {
            id: opNameModemText
            text: i18n("Operator Name (modem)")
            description: operatorName
        }

        FormCard.FormDelegateSeparator {}

        FormCard.FormTextDelegate  {
            id: opCodeSimText
            text: i18n("Operator Code (provided by SIM)")
            description: simOperatorIdentifier
        }

        FormCard.FormDelegateSeparator {}

        FormCard.FormTextDelegate {
            id: opNameSimText
            text: i18n("Operator Name (provided by SIM)")
            description: simOperatorName
        }

        FormCard.FormDelegateSeparator {}

        FormCard.FormTextDelegate {
            id: simIdText
            text: i18n("SIM ID")
            description: simIdentifier
        }

        FormCard.FormDelegateSeparator {}

        FormCard.AbstractFormDelegate {
            id: emergencyNumbersText

            background: null
            contentItem: ColumnLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing

                Controls.Label {
                    Layout.fillWidth: true
                    text: i18n("Emergency Numbers")
                    elide: Text.ElideRight
                }

                Repeater {
                    model: simEmergencyNumbers

                    Controls.Label {
                        Layout.fillWidth: true
                        text: modelData
                        color: Kirigami.Theme.disabledTextColor
                        font: Kirigami.Theme.smallFont
                        elide: Text.ElideRight
                    }
                }
            }
        }
    }
}
