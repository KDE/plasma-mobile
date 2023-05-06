// SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick 2.12
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.12 as Controls

import org.kde.kirigami 2.19 as Kirigami
import org.kde.kcm 1.2
import org.kde.kirigamiaddons.labs.mobileform 0.1 as MobileForm

import cellularnetworkkcm 1.0

Kirigami.ScrollablePage {
    id: root
    title: i18n("SIM Lock")
    
    leftPadding: 0
    rightPadding: 0
    topPadding: Kirigami.Units.gridUnit
    bottomPadding: Kirigami.Units.gridUnit
    
    property Sim sim

    ColumnLayout {
        spacing: 0
        width: root.width
        
        MessagesList {
            Layout.fillWidth: true
            Layout.margins: Kirigami.Units.largeSpacing
            model: kcm.messages
        }

        ColumnLayout {
            id: unlockSimPlaceholder
            visible: sim.locked
            Layout.fillWidth: true
            
            // HACK: prevent infinite binding loop?
            Component.onCompleted: unlockSimPlaceholder.Layout.preferredHeight = root.height
            
            Kirigami.PlaceholderMessage {
                Layout.margins: Kirigami.Units.gridUnit * 2
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: i18n("SIM is locked")
                explanation: i18n("In order to use this SIM, you must first unlock it.")
                icon.name: "lock"
                helpfulAction: Kirigami.Action {
                    icon.name: "unlock"
                    text: "Unlock SIM"
                    onTriggered: unlockPinDialog.open() // TODO replace custom unlock pin dialog with just opening the system unlock PIN dialog
                }
            }
        }
        
        ColumnLayout {
            id: notLockedSimPlaceholder
            visible: !sim.pinEnabled && !unlockSimPlaceholder.visible
            Layout.fillWidth: true
            
            // HACK: prevent infinite binding loop?
            Component.onCompleted: notLockedSimPlaceholder.Layout.preferredHeight = root.height
            
            Kirigami.PlaceholderMessage {
                Layout.margins: Kirigami.Units.gridUnit * 2
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: i18n("SIM is not locked")
                explanation: i18n("You can lock your SIM to require a set PIN code for phone calls and mobile data.")
                icon.name: "unlock"
                helpfulAction: Kirigami.Action {
                    icon.name: "lock"
                    text: i18n("Lock SIM")
                    onTriggered: createPinDialog.open()
                }
            }
        }
        
        MobileForm.FormCard {
            visible: !notLockedSimPlaceholder.visible && !unlockSimPlaceholder.visible
            Layout.fillWidth: true
            
            contentItem: ColumnLayout {
                spacing: 0
                MobileForm.FormButtonDelegate {
                    id: disableSimLockButton
                    text: i18n("Disable SIM Lock") 
                    description: i18n("Disable the SIM lock feature and remove the passcode on the SIM.")
                    onClicked: removePinDialog.open();
                }
                
                Kirigami.Separator {
                    Layout.leftMargin: Kirigami.Units.largeSpacing
                    Layout.rightMargin: Kirigami.Units.largeSpacing
                    Layout.fillWidth: true
                    opacity: (!disableSimLockButton.controlHovered && !changePinButton.controlHovered) ? 0.5 : 0
                }
                
                MobileForm.FormButtonDelegate {
                    id: changePinButton
                    text: i18n("Change PIN")
                    description: i18n("Change the passcode set on the SIM.")
                    onClicked: changePinDialog.open()
                }
            }
        }
        
        // dialogs
        
        RegExpValidator {
            id: pinValidator
            regExp: /[0-9]+/
        }
        
        Kirigami.Dialog {
            id: unlockPinDialog
            title: i18n("Unlock SIM")
            standardButtons: Controls.Dialog.Ok | Controls.Dialog.Cancel
            padding: Kirigami.Units.largeSpacing
            
            onAccepted: sim.sendPin(unlockPinCurPin.text)
            
            ColumnLayout {
                Controls.Label {
                    text: i18n("Attempts left: %1", sim.unlockRetriesLeft)
                }
                Kirigami.PasswordField {
                    id: unlockPinCurPin
                    placeholderText: i18n("Enter PIN")
                    validator: pinValidator
                }
            }
        }
        
        Kirigami.Dialog {
            id: changePinDialog
            title: i18n("Change SIM PIN")
            standardButtons: isValid ? Controls.Dialog.Ok | Controls.Dialog.Cancel : Controls.Dialog.Cancel
            padding: Kirigami.Units.largeSpacing
            
            property bool isValid: changePinNewPin.text == changePinConfirmPin.text && 
                                   changePinNewPin.text.length >= 4 && changePinNewPin.text.length <= 8 // SIM PINs are between 4-8 digits
            
            onAccepted: {
                if (isValid) {
                    sim.changePin(changePinCurPin.text, changePinNewPin.text);
                }
            }
            
            ColumnLayout {
                spacing: Kirigami.Units.smallSpacing
                Kirigami.InlineMessage {
                    id: changePinMatch
                    Layout.fillWidth: true
                    visible: changePinNewPin.text != changePinConfirmPin.text
                    text: i18n("PINs don't match!")
                    type: Kirigami.MessageType.Error
                }
                Kirigami.InlineMessage {
                    Layout.fillWidth: true
                    visible: !changePinMatch.visible && changePinNewPin.text.length != 0 && (changePinNewPin.text.length < 4 || changePinNewPin.text.length > 8)
                    text: i18n("PINs must be between 4 and 8 digits!")
                    type: Kirigami.MessageType.Error
                }
                Kirigami.PasswordField {
                    id: changePinCurPin
                    placeholderText: i18n("Current PIN")
                    validator: pinValidator
                }
                Kirigami.PasswordField {
                    id: changePinNewPin
                    placeholderText: i18n("New PIN")
                    validator: pinValidator
                }
                Kirigami.PasswordField {
                    id: changePinConfirmPin
                    placeholderText: i18n("Confirm PIN")
                    validator: pinValidator
                }
            }
        }
        
        Kirigami.Dialog {
            id: removePinDialog
            title: i18n("Remove SIM PIN")
            standardButtons: Controls.Dialog.Ok | Controls.Dialog.Cancel 
            padding: Kirigami.Units.largeSpacing
            
            onAccepted: sim.togglePinEnabled(removePinCurPin.text);
            
            ColumnLayout {
                Kirigami.PasswordField {
                    id: removePinCurPin
                    placeholderText: i18n("Current PIN")
                    validator: pinValidator
                }
            }
        }
        
        Kirigami.Dialog {
            id: createPinDialog
            title: i18n("Add SIM PIN")
            standardButtons: isValid ? Controls.Dialog.Ok | Controls.Dialog.Cancel : Controls.Dialog.Cancel
            padding: Kirigami.Units.largeSpacing
            
            property bool isValid: createPinNewPin.text == createPinConfirmPin.text && 
                                   createPinNewPin.text.length >= 4 && createPinNewPin.text.length <= 8 // SIM PINs are between 4-8 digits
            
            onAccepted: {
                if (isValid) {
                    sim.togglePinEnabled(createPinNewPin.text);
                }
            }
            
            ColumnLayout {
                spacing: Kirigami.Units.smallSpacing
                Kirigami.InlineMessage {
                    id: createPinMatch
                    Layout.fillWidth: true
                    visible: createPinNewPin.text != createPinConfirmPin.text
                    text: i18n("PINs don't match!")
                    type: Kirigami.MessageType.Error
                }
                Kirigami.InlineMessage {
                    Layout.fillWidth: true
                    visible: !createPinMatch.visible && createPinNewPin.text.length != 0 && (createPinNewPin.text.length < 4 || createPinNewPin.text.length > 8)
                    text: i18n("PINs must be between 4 and 8 digits!")
                    type: Kirigami.MessageType.Error
                }
                Kirigami.PasswordField {
                    id: createPinNewPin
                    placeholderText: i18n("New PIN")
                    validator: pinValidator
                }
                Kirigami.PasswordField {
                    id: createPinConfirmPin
                    placeholderText: i18n("Confirm PIN")
                    validator: pinValidator
                }
            }
        }
    }
}

