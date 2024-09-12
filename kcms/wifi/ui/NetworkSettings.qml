// SPDX-FileCopyrightText: 2017 Martin Kacej <m.kacej@atlas.sk>
// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls

import org.kde.kirigami as Kirigami
import org.kde.plasma.networkmanagement as PlasmaNM
import org.kde.kcmutils
import org.kde.kirigamiaddons.formcard 1 as FormCard

Kirigami.ScrollablePage {
    title: path ?  wirelessSettings["ssid"] : i18n("Add New Connection")

    property var path

    property var wirelessSettings: ({})
    property var securitySettings: ({})
    property var ipSettings: ({})
    property var secrets: ({})

    property var ipRegex: /^(([01]?[0-9]?[0-9]|2([0-4][0-9]|5[0-5]))\.){3}([01]?[0-9]?[0-9]|2([0-4][0-9]|5[0-5]))$/

    property bool enabledSave: (ipMethodCombobox.currentIndex == 0
                                || (ipMethodCombobox.currentIndex == 1
                                    && manualIPaddress.acceptableInput
                                    && manualIPgateway.acceptableInput
                                    && manualIPprefix.acceptableInput
                                    && manualIPdns.acceptableInput))

    actions: [
        Kirigami.Action {
            icon.name: "dialog-ok"
            text: i18n("Save")
            enabled: enabledSave
            onTriggered: {
                save()
                kcm.pop()
            }
        }
    ]

    topPadding: Kirigami.Units.gridUnit
    bottomPadding: Kirigami.Units.gridUnit
    leftPadding: 0
    rightPadding: 0

    ColumnLayout {
        FormCard.FormHeader {
            title: i18nc("@title:group", "General")
        }

        FormCard.FormCard {
            FormCard.FormTextFieldDelegate {
                id: ssidField
                label: i18n("SSID")
                text: wirelessSettings["ssid"] ? wirelessSettings["ssid"] : ""
                enabled: true
                onTextChanged: {
                    ipSettings["id"] = text
                }
            }

            FormCard.FormDelegateSeparator {
                above: ssidField
                below: hidden
            }

            FormCard.FormSwitchDelegate {
                id: hidden
                text: i18n("Hidden Network")
                checked: wirelessSettings["hidden"] ? wirelessSettings["hidden"] : false
                onToggled: ipSettings["hidden"] = checked
            }
        }

        FormCard.FormHeader {
            title: i18nc("@title:group", "Security")
        }

        FormCard.FormCard {
            FormCard.FormComboBoxDelegate {
                id: securityCombobox
                currentIndex: 0
                text: i18n("Security type")
                model: ListModel {
                    id: securityTypesModel
                    // FIXME just placeholder element to set "text" property as default
                    ListElement {
                        text: "placeholder"
                    }
                    function load() {
                        clear();
                        append({ "text": i18n("None"), "type": PlasmaNM.Enums.NoneSecurity });
                        append({ "text": i18n("WEP Key"), "type": PlasmaNM.Enums.StaticWep });
                        append({ "text": i18n("Dynamic WEP"), "type": PlasmaNM.Enums.DynamicWep });
                        append({ "text": i18n("WPA/WPA2 Personal"), "type": PlasmaNM.Enums.Wpa2Psk });
                        append({ "text": i18n("WPA/WPA2 Enterprise"), "type": PlasmaNM.Enums.Wpa2Eap });
                        append({ "text": i18n("WPA3 Personal"), "type": PlasmaNM.Enums.SAE });
                        append({ "text": i18n("WPA3 Enterprise"), "type": PlasmaNM.Enums.Wpa3SuiteB192 });

                        // See https://networkmanager.dev/docs/api/latest/settings-802-11-wireless-security.html
                        switch (securitySettings["key-mgmt"]) {
                        case "none":
                            securityCombobox.currentIndex = 0;
                            break;
                        case "ieee8021x":
                            securityCombobox.currentIndex = 1;
                            break;
                        case "wpa-psk":
                            securityCombobox.currentIndex = 3;
                            break;
                        case "wpa-eap":
                            securityCombobox.currentIndex = 4;
                            break;
                        case "sae":
                            securityCombobox.currentIndex = 5;
                            break;
                        case "wpa-eap-suite-b-192":
                            securityCombobox.currentIndex = 6;
                            break;
                        default:
                            securityCombobox.currentIndex = 0;
                            break;
                        }
                    }
                }
            }

            FormCard.FormDelegateSeparator {
                above: securityCombobox
                below: passwordDelegate
                visible: passwordDelegate.visible
            }

            FormCard.FormTextFieldDelegate {
                id: passwordDelegate
                label: i18n("Password")
                echoMode: TextInput.Password
                inputMethodHints: Qt.ImhHiddenText
                text: secrets["psk"]
                visible: securityTypesModel.get(securityCombobox.currentIndex).type !== PlasmaNM.Enums.NoneSecurity
                onTextChanged: securitySettings["password"] = text
            }

            FormCard.FormDelegateSeparator {
                above: passwordDelegate
                below: authComboBox
                visible: authComboBox.visible
            }

            FormCard.FormComboBoxDelegate {
                id: authComboBox
                text: i18n("Authentication:")
                currentIndex: 0
                visible: securityCombobox.currentIndex === 2
                        || securityCombobox.currentIndex === 4
                model: [i18n("TLS"), i18n("LEAP"), i18n("FAST"), i18n(
                        "Tunneled TLS"), i18n(
                        "Protected EAP")] // more - SIM, AKA, PWD ?
            }

            Controls.Label {
                visible: ![0, 3, 5].includes(securityCombobox.currentIndex) // only supports WPA PSK, SAE
                text: "----Not yet implemented----"
                color: "red"
            }
        }

        FormCard.FormHeader {
            title: i18nc("@title:group", "IP Settings")
        }

        FormCard.FormCard {
            FormCard.FormComboBoxDelegate {
                id: ipMethodCombobox
                text: i18n('Method')
                model: [i18n("Automatic"), i18n("Manual")]
                currentIndex: ipSettings["method"] === "manual" ? 1 : 0
                property var manualIp: currentIndex === 1
                onCurrentIndexChanged: {
                    ipSettings["method"] = currentIndex === 1 ? "manual" : "auto"
                }
            }

            FormCard.FormDelegateSeparator {
                above: ipMethodCombobox
                below: manualIPaddress
                visible: manualIPaddress.visible
            }

            FormCard.FormTextFieldDelegate {
                id: manualIPaddress
                label: i18n("IP Address")
                visible: ipMethodCombobox.manualIp
                placeholderText: "192.168.1.128"
                text: ipSettings["address"] ? ipSettings["address"] : ""
                onTextChanged: ipSettings["address"] = text
                validator: RegularExpressionValidator {
                    regularExpression: ipRegex
                }
            }

            FormCard.FormDelegateSeparator {
                above: manualIPaddress
                below: manualIPgateway
                visible: manualIPgateway.visible
            }

            FormCard.FormTextFieldDelegate {
                id: manualIPgateway
                label: i18n("Gateway")
                visible: ipMethodCombobox.manualIp
                placeholderText: "192.168.1.1"
                text: ipSettings["gateway"] ? ipSettings["gateway"] : ""
                onTextChanged: ipSettings["gateway"] = text
                validator: RegularExpressionValidator {
                    regularExpression: ipRegex
                }
            }

            FormCard.FormDelegateSeparator {
                above: manualIPgateway
                below: manualIPprefix
                visible: manualIPprefix.visible
            }

            FormCard.FormTextFieldDelegate {
                id: manualIPprefix
                label: i18n("Network prefix length")
                visible: ipMethodCombobox.manualIp
                placeholderText: "16"
                text: ipSettings["prefix"] ? ipSettings["prefix"] : ""
                onTextChanged: ipSettings["prefix"] = text
                validator: IntValidator {
                    bottom: 1
                    top: 32
                }
            }

            FormCard.FormDelegateSeparator {
                above: manualIPprefix
                below: manualIPdns
                visible: manualIPdns.visible
            }

            FormCard.FormTextFieldDelegate {
                id: manualIPdns
                label: i18n("DNS")
                visible: ipMethodCombobox.manualIp
                placeholderText: "8.8.8.8"
                text: ipSettings["dns"] ? ipSettings["dns"] : ""
                onTextChanged: ipSettings["dns"] = text
                validator: RegularExpressionValidator {
                    regularExpression: ipRegex
                }
            }
        }
    }

    Component.onCompleted: {
        wirelessSettings = kcm.getConnectionSettings(path, "802-11-wireless")
        securitySettings = kcm.getConnectionSettings(path, "802-11-wireless-security")
        ipSettings = kcm.getConnectionSettings(path, "ipv4")
        secrets = kcm.getConnectionSettings(path, "secrets")

        securityTypesModel.load()
    }

    function save() {
        var settings = ipSettings
        settings["mode"] = "infrastructure"
        securitySettings["type"] = securityTypesModel.get(securityCombobox.currentIndex).type
        settings["802-11-wireless-security"] = securitySettings

        if (path)
            kcm.updateConnectionFromQML(path, settings)
        else
            kcm.addConnectionFromQML(settings)
    }
}
