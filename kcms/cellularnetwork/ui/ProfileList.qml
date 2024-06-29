// SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami

import cellularnetworkkcm

import org.kde.kirigamiaddons.formcard 1 as FormCard

Kirigami.ScrollablePage {
    id: root
    topPadding: Kirigami.Units.gridUnit
    bottomPadding: Kirigami.Units.gridUnit
    leftPadding: 0
    rightPadding: 0

    property Modem modem
    property bool editMode: false
    
    title: i18n("APNs")
    actions: [
        Kirigami.Action {
            text: i18n("Edit")
            icon.name: 'entry-edit'
            checkable: true
            onCheckedChanged: root.editMode = checked
        }
    ]

    ColumnLayout {
        spacing: 0

        MessagesList {
            id: messagesList
            visible: count != 0
            Layout.fillWidth: true
            Layout.margins: Kirigami.Units.largeSpacing
            model: kcm.messages
        }
        
        Kirigami.InlineMessage {
            id: cannotFindWarning
            Layout.margins: visible ? Kirigami.Units.largeSpacing : 0
            Layout.topMargin: visible && !messagesList.visible ? Kirigami.Units.largeSpacing : 0
            Layout.fillWidth: true
            
            visible: false
            type: Kirigami.MessageType.Warning
            showCloseButton: true
            text: i18n("Unable to autodetect connection settings for your carrier. Please find your carrier's APN settings by either contacting support or searching online.")
            
            Connections {
                target: modem
                function onCouldNotAutodetectSettings() {
                    cannotFindWarning.visible = true;
                }
            }
        }
        
        FormCard.FormHeader {
            title: i18n("APN List")
        }

        FormCard.FormCard {
            Repeater {
                id: profilesRepeater
                model: modem.profiles

                delegate: FormCard.FormRadioDelegate {
                    text: modelData.name
                    description: modelData.apn

                    checked: modem.activeConnectionUni == modelData.connectionUni
                    onClicked: {
                        modem.activateProfile(modelData.connectionUni);

                        // reapply binding
                        checked = Qt.binding(() => { return modem.activeConnectionUni == modelData.connectionUni });
                    }

                    trailing: RowLayout {
                        Controls.ToolButton {
                            visible: root.editMode
                            icon.name: "entry-edit"
                            text: i18n("Edit")
                            display: Controls.ToolButton.IconOnly
                            onClicked: {
                                kcm.push("EditProfilePage.qml", { "profile": modelData, "modem": modem });
                            }
                        }

                        Controls.ToolButton {
                            visible: root.editMode
                            icon.name: "delete"
                            text: i18n("Delete")
                            display: Controls.ToolButton.IconOnly
                            onClicked: modem.removeProfile(modelData.connectionUni)
                        }
                    }
                }
            }

            FormCard.FormButtonDelegate {
                text: i18n("Add APN")
                icon.name: 'list-add'
                onClicked: {
                    kcm.push("EditProfilePage.qml", { "profile": null, "modem": modem });
                }
            }
            
            FormCard.FormButtonDelegate {
                text: i18n("Automatically detect APN")
                icon.name: 'list-add'
                onClicked: {
                    modem.addDetectedProfileSettings();
                }
            }
        }
    }
}
