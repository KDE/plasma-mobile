// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import org.kde.kirigami as Kirigami
import org.kde.kirigamiaddons.formcard 1 as FormCard
import org.kde.plasma.networkmanagement.cellular as Cellular

import org.kde.plasma.mobileinitialstart.initialstart

InitialStartModule {
    name: i18n("Cellular")
    available: modemList.modemAvailable
    contentItem: Item {
        id: root

        Cellular.CellularModemList {
            id: modemList
        }

        property Cellular.CellularModem modem: modemList.primaryModem

        readonly property real cardWidth: Math.min(Kirigami.Units.gridUnit * 30, root.width - Kirigami.Units.gridUnit * 2)

        function toggleMobileData() {
            if (!root.modem || root.modem.needsAPNAdded || !root.modem.mobileDataSupported) {
                MobileShell.ShellUtil.executeCommand("plasma-open-settings kcm_cellular_network");
            } else {
                root.modem.mobileDataEnabled = !root.modem.mobileDataEnabled;
            }
        }

        EditProfileDialog {
            id: profileDialog
            modem: root.modem
        }

        ColumnLayout {
            anchors {
                fill: parent
                topMargin: Kirigami.Units.gridUnit
                bottomMargin: Kirigami.Units.largeSpacing
            }
            width: root.width
            spacing: Kirigami.Units.gridUnit

            Label {
                Layout.leftMargin: Kirigami.Units.gridUnit
                Layout.rightMargin: Kirigami.Units.gridUnit
                Layout.alignment: Qt.AlignTop
                Layout.fillWidth: true

                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
                text: {
                    if (!root.modem) {
                        return i18n("Your device does not have a modem available.");
                    } else if (root.modem.needsAPNAdded) {
                        return i18n("Please configure your APN below for mobile data, further information will be available with your carrier.");
                    } else if (root.modem.mobileDataSupported) {
                        return i18n("You are connected to the mobile network.");
                    } else if (root.modem.simEmpty) {
                        return i18n("Please insert a SIM card into your device.");
                    } else {
                        return i18n("Your device does not have a modem available.");
                    }
                }
            }

            FormCard.FormCard {
                visible: root.modem && root.modem.mobileDataSupported
                maximumWidth: root.cardWidth

                Layout.alignment: Qt.AlignTop | Qt.AlignHCenter

                FormCard.FormSwitchDelegate {
                    text: i18n("Mobile Data")
                    checked: root.modem ? root.modem.mobileDataEnabled : false
                    onCheckedChanged: {
                        if (root.modem && checked !== root.modem.mobileDataEnabled) {
                            root.toggleMobileData();
                        }
                    }
                }
            }

            FormCard.FormCard {
                visible: root.modem && !root.modem.simEmpty
                maximumWidth: root.cardWidth

                Layout.fillHeight: true
                Layout.alignment: Qt.AlignTop | Qt.AlignHCenter

                ListView {
                    id: listView
                    currentIndex: -1
                    clip: true

                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    model: root.modem ? root.modem.profiles : null

                    delegate: FormCard.FormRadioDelegate {
                        required property int index
                        required property string connectionName
                        required property string connectionAPN
                        required property string connectionUni

                        width: listView.width
                        text: connectionName
                        description: connectionAPN
                        checked: root.modem && root.modem.activeConnectionUni === connectionUni

                        onCheckedChanged: {
                            if (checked && root.modem) {
                                root.modem.activateProfile(connectionUni);
                                checked = Qt.binding(() => { return root.modem && root.modem.activeConnectionUni === connectionUni });
                            }
                        }

                        trailing: RowLayout {
                            ToolButton {
                                icon.name: "entry-edit"
                                text: i18n("Edit")
                                onClicked: {
                                    profileDialog.editConnectionUni = connectionUni;
                                    profileDialog.open();
                                }
                            }
                            ToolButton {
                                icon.name: "delete"
                                text: i18n("Delete")
                                onClicked: root.modem.removeProfile(connectionUni)
                            }
                        }
                    }
                }

                FormCard.FormButtonDelegate {
                    icon.name: "list-add"
                    text: i18n("Add APN")
                    onClicked: {
                        profileDialog.editConnectionUni = "";
                        profileDialog.open();
                    }
                }
            }
        }
    }
}
