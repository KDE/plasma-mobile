// SPDX-FileCopyrightText: 2021-2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls

import org.kde.kirigami 2 as Kirigami
import org.kde.kcmutils
import org.kde.kirigamiaddons.formcard 1 as FormCard

import cellularnetworkkcm

FormCard.FormCardPage {
    id: modemPage

    property Modem modem
    property bool showExtra: false

    title: i18n("Modem %1", modem.displayId)

    MessagesList {
        Layout.fillWidth: true
        Layout.margins: Kirigami.Units.smallSpacing
        visible: count != 0
        model: kcm.messages
    }

    FormCard.FormHeader {
        title: i18n("Modem Control")
    }

    FormCard.FormCard {
        FormCard.FormButtonDelegate {
            id: modemRestartButton
            text: i18n("Force Modem Restart")
            onClicked: modem.reset()
        }
    }

    FormCard.FormHeader {
        title: i18n("Modem Details")
    }

    FormCard.FormCard {
        FormCard.AbstractFormDelegate {
            id: accessTechnologiesText

            background: null
            contentItem: ColumnLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing
                Controls.Label {
                    Layout.fillWidth: true
                    text: i18n("Access Technologies")
                    elide: Text.ElideRight
                }
                Repeater {
                    model: modem.details.accessTechnologies
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

        FormCard.FormDelegateSeparator {}

        FormCard.FormTextDelegate {
            id: imeiText
            text: i18n("IMEI")
            description: modem.details.equipmentIdentifier
        }

        FormCard.FormDelegateSeparator {}

        FormCard.FormTextDelegate {
            id: enabledText
            text: i18n("Enabled")
            description: modem.details.isEnabled
        }

        FormCard.FormDelegateSeparator {}

        FormCard.FormTextDelegate {
            id: manufacturerText
            text: i18n("Manufacturer")
            description: modem.details.manufacturer
        }

        FormCard.FormDelegateSeparator {}

        FormCard.FormTextDelegate {
            id: modelText
            text: i18n("Model")
            description: modem.details.model
        }

        FormCard.FormDelegateSeparator {}

        FormCard.AbstractFormDelegate {
            id: ownedNumbersText

            background: null
            contentItem: ColumnLayout {
                spacing: Kirigami.Units.smallSpacing

                Controls.Label {
                    Layout.fillWidth: true
                    text: i18n("Owned Numbers:")
                    elide: Text.ElideRight
                }

                Repeater {
                    model: modem.details.ownNumbers
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

        FormCard.FormDelegateSeparator {}

        FormCard.FormTextDelegate {
            id: revisionText
            text: i18n("Revision")
            description: modem.details.revision
        }

        FormCard.FormDelegateSeparator {}

        FormCard.FormTextDelegate {
            id: signalQualityText
            text: i18n("Signal Quality")
            description: modem.details.signalQuality
        }

        FormCard.FormDelegateSeparator {}

        FormCard.FormTextDelegate {
            id: stateText
            text: i18n("State")
            description: modem.details.state
        }

        FormCard.FormDelegateSeparator {}

        FormCard.FormTextDelegate {
            id: failureReasonText
            text: i18n("Failure Reason")
            description: modem.details.stateFailedReason
        }

        FormCard.FormDelegateSeparator {}

        FormCard.FormTextDelegate {
            id: registrationStateText
            text: i18n("Registration State")
            description: modem.details.registrationState
        }

        FormCard.FormDelegateSeparator {}

        FormCard.FormTextDelegate {
            id: roamingText
            text: i18n("Roaming")
            description: modem.isRoaming ? i18n("Yes") : i18n("No")
        }

        FormCard.FormDelegateSeparator {}

        FormCard.FormTextDelegate {
            id: firmwareVersionText
            text: i18n("Firmware Version")
            description: modem.details.firmwareVersion
        }

        FormCard.FormDelegateSeparator {}

        FormCard.FormTextDelegate {
            id: interfaceNameText
            text: i18n("Interface Name")
            description: modem.details.interfaceName
        }

        FormCard.FormDelegateSeparator {}

        FormCard.FormTextDelegate {
            id: meteredText
            text: i18n("Metered")
            description: modem.details.metered
        }

        FormCard.FormDelegateSeparator {}

        FormCard.FormTextDelegate {
            id: activeNMConnectionText
            text: i18n("Active NetworkManager Connection")
            description: modem.activeConnectionUni
        }

        FormCard.FormDelegateSeparator {}

        FormCard.FormTextDelegate {
            id: deviceText
            text: i18n("Device")
            description: modem.details.device
        }

        FormCard.FormDelegateSeparator {}

        FormCard.FormTextDelegate {
            id: deviceIdText
            text: i18n("Device ID")
            description: modem.details.deviceIdentifier
        }

        FormCard.FormDelegateSeparator {}

        FormCard.AbstractFormDelegate {
            id: driversText

            background: null
            contentItem: ColumnLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing
                Controls.Label {
                    Layout.fillWidth: true
                    text: i18n("Drivers:")
                    elide: Text.ElideRight
                }
                Repeater {
                    model: modem.details.drivers
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

        FormCard.FormDelegateSeparator {}

        FormCard.FormTextDelegate {
            id: pluginText
            text: i18n("Plugin")
            description: modem.details.plugin
        }

        FormCard.FormDelegateSeparator {}

        FormCard.FormTextDelegate {
            id: powerStateText
            text: i18n("Power State")
            description: modem.details.powerState
        }

        FormCard.FormDelegateSeparator {}

        FormCard.FormTextDelegate {
            id: simPathText
            text: i18n("SIM Path")
            description: modem.details.simPath
        }
    }
}

