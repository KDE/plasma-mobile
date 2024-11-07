// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import org.kde.kirigami as Kirigami
import org.kde.kirigamiaddons.formcard 1 as FormCard
import org.kde.plasma.mm as PlasmaMM

import org.kde.plasma.mobileinitialstart.initialstart

InitialStartModule {
    contentItem: Item {
        id: root
        property string name: i18n("Cellular")

        readonly property real cardWidth: Math.min(Kirigami.Units.gridUnit * 30, root.width - Kirigami.Units.gridUnit * 2)

        function toggleMobileData() {
            if (PlasmaMM.SignalIndicator.needsAPNAdded || !PlasmaMM.SignalIndicator.mobileDataSupported) {
                // open settings if unable to toggle mobile data
                MobileShell.ShellUtil.executeCommand("plasma-open-settings kcm_cellular_network");
            } else {
                PlasmaMM.SignalIndicator.mobileDataEnabled = !PlasmaMM.SignalIndicator.mobileDataEnabled;
            }
        }

        EditProfileDialog {
            id: profileDialog
            profile: null
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
                    if (!PlasmaMM.SignalIndicator.modemAvailable) {
                        return i18n("Your device does not have a modem available.");
                    } else if (PlasmaMM.SignalIndicator.needsAPNAdded) {
                        return i18n("Please configure your APN below for mobile data, further information will be available with your carrier.");
                    } else if (PlasmaMM.SignalIndicator.mobileDataSupported) {
                        return i18n("You are connected to the mobile network.");
                    } else if (PlasmaMM.SignalIndicator.simEmpty) {
                        return i18n("Please insert a SIM card into your device.");
                    } else {
                        return i18n("Your device does not have a modem available.");
                    }
                }
            }

            FormCard.FormCard {
                visible: PlasmaMM.SignalIndicator.modemAvailable && PlasmaMM.SignalIndicator.mobileDataSupported
                maximumWidth: root.cardWidth

                Layout.alignment: Qt.AlignTop | Qt.AlignHCenter

                FormCard.FormSwitchDelegate {
                    text: i18n("Mobile Data")
                    checked: PlasmaMM.SignalIndicator.mobileDataEnabled
                    onCheckedChanged: {
                        if (checked !== PlasmaMM.SignalIndicator.mobileDataEnabled) {
                            root.toggleMobileData();
                        }
                    }
                }
            }

            FormCard.FormCard {
                visible: PlasmaMM.SignalIndicator.modemAvailable && !PlasmaMM.SignalIndicator.simEmpty
                maximumWidth: root.cardWidth

                Layout.fillHeight: true
                Layout.alignment: Qt.AlignTop | Qt.AlignHCenter

                ListView {
                    id: listView
                    currentIndex: -1
                    clip: true

                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    model: PlasmaMM.SignalIndicator.profiles

                    delegate: FormCard.FormRadioDelegate {
                        width: listView.width
                        text: modelData.name
                        description: modelData.apn
                        checked: modem.activeConnectionUni == modelData.connectionUni

                        onCheckedChanged: {
                            if (checked) {
                                PlasmaMM.SignalIndicator.activateProfile(modelData.connectionUni);
                                checked = Qt.binding(() => { return modem.activeConnectionUni == modelData.connectionUni });
                            }
                        }

                        trailing: RowLayout {
                            ToolButton {
                                icon.name: "entry-edit"
                                text: i18n("Edit")
                                onClicked: {
                                    profileDialog.profile = modelData;
                                    profileDialog.open();
                                }
                            }
                            ToolButton {
                                icon.name: "delete"
                                text: i18n("Delete")
                                onClicked: PlasmaMM.SignalIndicator.removeProfile(modelData.connectionUni)
                            }
                        }
                    }
                }

                FormCard.FormButtonDelegate {
                    icon.name: "list-add"
                    text: i18n("Add APN")
                    onClicked: {
                        profileDialog.profile = null;
                        profileDialog.open();
                    }
                }
            }
        }
    }
}
