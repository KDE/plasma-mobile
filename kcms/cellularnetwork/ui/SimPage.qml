// SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick 2.12
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.12 as Controls

import org.kde.kirigami 2.12 as Kirigami
import org.kde.plasma.networkmanagement 0.2 as PlasmaNM
import org.kde.kcm 1.2
import org.kde.kirigamiaddons.labs.mobileform 0.1 as MobileForm

import cellularnetworkkcm 1.0

Kirigami.ScrollablePage {
    id: simPage
    title: i18n("SIM") + " " + displayId
    
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
    
    leftPadding: 0
    rightPadding: 0
    topPadding: Kirigami.Units.gridUnit
    bottomPadding: Kirigami.Units.gridUnit
    
    PlasmaNM.EnabledConnections {
        id: enabledConnections
    }
    
    ColumnLayout {
        spacing: 0
        width: simPage.width
        
        Kirigami.InlineMessage {
            Layout.fillWidth: true
            Layout.margins: Kirigami.Units.largeSpacing
            Layout.bottomMargin: visible && !messagesList.visible ? Kirigami.Units.largeSpacing : 0
            visible: !simEnabled
            type: Kirigami.MessageType.Error
            text: qsTr("This SIM slot is empty, a SIM card needs to be inserted in order for it to be used.")
        }
        
        MessagesList {
            id: messagesList
            Layout.fillWidth: true
            Layout.margins: Kirigami.Units.largeSpacing
            model: kcm.messages
        }
        
        MobileForm.FormCard {
            Layout.fillWidth: true
            
            contentItem: ColumnLayout {
                spacing: 0
                
                MobileForm.FormSwitchDelegate {
                    id: dataRoamingCheckBox
                    text: i18n("Data Roaming")
                    description: i18n("Allow your device to use networks other than your carrier.")
                    enabled: simEnabled
                    checked: isRoaming
                    onCheckedChanged: sim.modem.isRoaming = checked
                }
                
                MobileForm.FormDelegateSeparator { above: dataRoamingCheckBox; below: apnButton }
                
                MobileForm.FormButtonDelegate {
                    id: apnButton
                    icon.name: "globe"
                    text: i18n("Modify APNs")
                    description: i18n("Configure access point names for your carrier.")
                    enabled: simEnabled && enabledConnections.wwanEnabled
                    onClicked: kcm.push("ProfileList.qml", { "modem": sim.modem });
                }
                
                MobileForm.FormDelegateSeparator { above: apnButton; below: networksButton }
                
                MobileForm.FormButtonDelegate {
                    id: networksButton
                    icon.name: "network-mobile-available"
                    text: i18n("Networks")
                    description: i18n("Select a network operator.")
                    enabled: simEnabled
                    onClicked: kcm.push("AvailableNetworks.qml", { "modem": sim.modem, "sim": sim });
                }
                
                MobileForm.FormDelegateSeparator { above: networksButton; below: simLockButton }
                
                MobileForm.FormButtonDelegate {
                    id: simLockButton
                    icon.name: "unlock"
                    text: i18n("SIM Lock")
                    description: i18n("Modify SIM lock settings.")
                    enabled: simEnabled
                    onClicked: kcm.push("SimLockPage.qml", { "sim": sim });
                }
                
                MobileForm.FormDelegateSeparator { above: simLockButton; below: modemDetailsButton }
                
                MobileForm.FormButtonDelegate {
                    id: modemDetailsButton
                    icon.name: "network-modem"
                    text: i18n("Modem Details")
                    description: i18n("View the details of the modem this SIM is connected to.")
                    onClicked: kcm.push("ModemPage.qml", { "modem": sim.modem })
                }
            }
        }
        
        MobileForm.FormCard {
            Layout.fillWidth: true
            Layout.topMargin: Kirigami.Units.largeSpacing
            
            contentItem: ColumnLayout {
                spacing: 0
                
                MobileForm.FormCardHeader {
                    title: i18n("SIM Details")
                }
                
                MobileForm.FormTextDelegate {
                    id: lockedText
                    text: i18n("Locked")
                    description: simLocked ? i18n("Yes") : i18n("No")
                }
                
                MobileForm.FormDelegateSeparator {}
                
                MobileForm.FormTextDelegate  {
                    id: imsiText
                    text: i18n("IMSI")
                    description: simImsi
                }
                
                MobileForm.FormDelegateSeparator {}
                
                MobileForm.FormTextDelegate  {
                    id: eidText
                    text: i18n("EID")
                    description: simEid
                }
                
                MobileForm.FormDelegateSeparator {}
                
                MobileForm.FormTextDelegate {
                    id: opCodeModemText
                    text: i18n("Operator Code (modem)")
                    description: operatorCode
                }
                
                MobileForm.FormDelegateSeparator {}
                
                MobileForm.FormTextDelegate  {
                    id: opNameModemText
                    text: i18n("Operator Name (modem)")
                    description: operatorName
                }
                
                MobileForm.FormDelegateSeparator {}
                
                MobileForm.FormTextDelegate  {
                    id: opCodeSimText
                    text: i18n("Operator Code (provided by SIM)")
                    description: simOperatorIdentifier
                }
                
                MobileForm.FormDelegateSeparator {}
                
                MobileForm.FormTextDelegate {
                    id: opNameSimText
                    text: i18n("Operator Name (provided by SIM)")
                    description: simOperatorName
                }
                
                MobileForm.FormDelegateSeparator {}
                
                MobileForm.FormTextDelegate {
                    id: simIdText
                    text: i18n("SIM ID")
                    description: simIdentifier
                }
                
                MobileForm.FormDelegateSeparator {}
                
                MobileForm.AbstractFormDelegate {
                    id: emergencyNumbersText
                    Layout.fillWidth: true
                    
                    background: Item {}
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
    }
}
