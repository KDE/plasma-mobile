// SPDX-FileCopyrightText: 2021-2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick 2.12
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.12 as Controls

import org.kde.kirigami 2.19 as Kirigami
import org.kde.kcmutils
import org.kde.kirigamiaddons.labs.mobileform 0.1 as MobileForm

import cellularnetworkkcm 1.0

Kirigami.ScrollablePage {
    id: modemPage
    title: i18n("Modem %1", modem.displayId)
    
    leftPadding: 0
    rightPadding: 0
    topPadding: Kirigami.Units.gridUnit
    bottomPadding: Kirigami.Units.gridUnit
    
    property Modem modem
    property bool showExtra: false
    
    ColumnLayout {
        MessagesList {
            Layout.fillWidth: true
            Layout.margins: Kirigami.Units.smallSpacing
            visible: count != 0
            model: kcm.messages
        }
        
        MobileForm.FormCard {
            Layout.fillWidth: true
            
            contentItem: ColumnLayout {
                spacing: 0
                
                MobileForm.FormCardHeader {
                    title: i18n("Modem Control")
                }
                
                MobileForm.AbstractFormDelegate {
                    id: modemRestartButton
                    Layout.fillWidth: true
                    contentItem: RowLayout {
                        Controls.Label {
                            Layout.fillWidth: true
                            text: i18n("Modem Restart")
                        }
                        Controls.Button {
                            text: i18n("Force Modem Restart")
                            onClicked: modem.reset()
                        }
                    }
                }
            }
        }
        
        MobileForm.FormCard {
            Layout.fillWidth: true
            Layout.topMargin: Kirigami.Units.gridUnit
            
            contentItem: ColumnLayout {
                spacing: 0
                
                MobileForm.FormCardHeader {
                    title: i18n("Modem Details")
                }
                
                MobileForm.AbstractFormDelegate {
                    id: accessTechnologiesText
                    Layout.fillWidth: true
                    
                    background: Item {}
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
                
                MobileForm.FormDelegateSeparator {}
                
                MobileForm.FormTextDelegate {
                    id: imeiText
                    text: i18n("IMEI")
                    description: modem.details.equipmentIdentifier
                }
                
                MobileForm.FormDelegateSeparator {}
                
                MobileForm.FormTextDelegate {
                    id: enabledText
                    text: i18n("Enabled")
                    description: modem.details.isEnabled
                }
                
                MobileForm.FormDelegateSeparator {}
                
                MobileForm.FormTextDelegate {
                    id: manufacturerText
                    text: i18n("Manufacturer")
                    description: modem.details.manufacturer
                }
                
                MobileForm.FormDelegateSeparator {}
                
                MobileForm.FormTextDelegate {
                    id: modelText
                    text: i18n("Model")
                    description: modem.details.model
                }
                
                MobileForm.FormDelegateSeparator {}
                
                MobileForm.AbstractFormDelegate {
                    id: ownedNumbersText
                    Layout.fillWidth: true
                    
                    background: Item {}
                    contentItem: ColumnLayout {
                        Layout.fillWidth: true
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
                
                MobileForm.FormDelegateSeparator {}

                MobileForm.FormTextDelegate {
                    id: revisionText
                    text: i18n("Revision")
                    description: modem.details.revision
                }
                
                MobileForm.FormDelegateSeparator {}
                
                MobileForm.FormTextDelegate {
                    id: signalQualityText
                    text: i18n("Signal Quality")
                    description: modem.details.signalQuality
                }
                
                MobileForm.FormDelegateSeparator {}
                
                MobileForm.FormTextDelegate {
                    id: stateText
                    text: i18n("State")
                    description: modem.details.state
                }
                
                MobileForm.FormDelegateSeparator {}
                
                MobileForm.FormTextDelegate {
                    id: failureReasonText
                    text: i18n("Failure Reason")
                    description: modem.details.stateFailedReason
                }
                
                MobileForm.FormDelegateSeparator {}
                
                MobileForm.FormTextDelegate {
                    id: registrationStateText
                    text: i18n("Registration State")
                    description: modem.details.registrationState
                }
                
                MobileForm.FormDelegateSeparator {}
                
                MobileForm.FormTextDelegate {
                    id: roamingText
                    text: i18n("Roaming")
                    description: modem.isRoaming ? i18n("Yes") : i18n("No")
                }
                
                MobileForm.FormDelegateSeparator {}
                
                MobileForm.FormTextDelegate {
                    id: firmwareVersionText
                    text: i18n("Firmware Version")
                    description: modem.details.firmwareVersion
                }
                
                MobileForm.FormDelegateSeparator {}
                
                MobileForm.FormTextDelegate {
                    id: interfaceNameText
                    text: i18n("Interface Name")
                    description: modem.details.interfaceName
                }
                
                MobileForm.FormDelegateSeparator {}
                
                MobileForm.FormTextDelegate {
                    id: meteredText
                    text: i18n("Metered")
                    description: modem.details.metered
                }
                
                MobileForm.FormDelegateSeparator {}
                
                MobileForm.FormTextDelegate {
                    id: activeNMConnectionText
                    text: i18n("Active NetworkManager Connection")
                    description: modem.activeConnectionUni
                }
                
                MobileForm.FormDelegateSeparator {}
                
                MobileForm.FormTextDelegate {
                    id: deviceText
                    text: i18n("Device")
                    description: modem.details.device
                }
                
                MobileForm.FormDelegateSeparator {}
                
                MobileForm.FormTextDelegate {
                    id: deviceIdText
                    text: i18n("Device ID")
                    description: modem.details.deviceIdentifier
                }
                
                MobileForm.FormDelegateSeparator {}
                
                MobileForm.AbstractFormDelegate {
                    id: driversText
                    Layout.fillWidth: true
                    
                    background: Item {}
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
                
                MobileForm.FormDelegateSeparator {}
                
                MobileForm.FormTextDelegate {
                    id: pluginText
                    text: i18n("Plugin")
                    description: modem.details.plugin
                }
                
                MobileForm.FormDelegateSeparator {}
                
                MobileForm.FormTextDelegate {
                    id: powerStateText
                    text: i18n("Power State")
                    description: modem.details.powerState
                }
                
                MobileForm.FormDelegateSeparator {}
                
                MobileForm.FormTextDelegate {
                    id: simPathText
                    text: i18n("SIM Path")
                    description: modem.details.simPath
                }
            }
        }
    }
}

