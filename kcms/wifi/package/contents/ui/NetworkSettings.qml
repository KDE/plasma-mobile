/*
    SPDX-FileCopyrightText: 2017 Martin Kacej <m.kacej@atlas.sk>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/
import QtQuick 2.15
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.2 as Controls
import org.kde.kirigami 2.3 as Kirigami
import org.kde.plasma.networkmanagement 0.2 as PlasmaNM
import org.kde.kcm 1.1

SimpleKCM {
    title: path ?  wirelessSettings["ssid"] : i18n("Add new Connection")

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

    Kirigami.FormLayout {
        Item {
            Kirigami.FormData.label: i18n("General")
            Kirigami.FormData.isSection: true
        }
        Controls.TextField {
            id: ssidField
            Kirigami.FormData.label: i18n("SSID:")
            text: wirelessSettings["ssid"] ? wirelessSettings["ssid"] : ""
            enabled: true
            onTextChanged: {
                ipSettings["id"] = text
            }
        }
        Controls.CheckBox {
            id: hidden
            Kirigami.FormData.label: i18n("Hidden Network:")
            checked: wirelessSettings["hidden"] ? wirelessSettings["hidden"] : false
            onToggled: ipSettings["hidden"] = checked
        }

        Kirigami.Separator {
            Kirigami.FormData.label: i18n("Security")
            Kirigami.FormData.isSection: true
        }

        Controls.ComboBox {
            id: securityCombobox
            Kirigami.FormData.label: i18n("Security type:")
            model: ListModel {
                id: securityTypesModel
                // FIXME just placeholder element to set "text" property as default
                ListElement {
                    text: "placeholder"
                }
                function load() {
                    clear()
                    append({ "text": i18n("None"), "type": PlasmaNM.Enums.NoneSecurity })
                    append({ "text": i18n("WEP Key"), "type": PlasmaNM.Enums.StaticWep })
                    append({ "text": i18n("Dynamic WEP"), "type": PlasmaNM.Enums.DynamicWep })
                    append({ "text": i18n("WPA/WPA2 Personal"), "type": PlasmaNM.Enums.Wpa2Psk })
                    append({ "text": i18n("WPA/WPA2 Enterprise"), "type": PlasmaNM.Enums.Wpa2Eap })
                    switch (securitySettings["key-mgmt"]) {
                    case "none":
                        securityCombobox.currentIndex = 0
                        break
                    case "ieee8021x":
                        securityCombobox.currentIndex = 1
                        break
                    case "wpa-psk":
                        securityCombobox.currentIndex = 3
                        break
                    case "wpa-eap":
                        securityCombobox.currentIndex = 4
                        break
                    default:
                        securityCombobox.currentIndex = 0
                        break
                    }
                }
            }

        }

        PasswordField {
            id: passwordField
            Kirigami.FormData.label: i18n("Password:")
            text: secrets["psk"]
            visible: securityTypesModel.get(securityCombobox.currentIndex).type !== PlasmaNM.Enums.NoneSecurity
            onTextChanged: securitySettings["password"] = text
        }

        Controls.ComboBox {
            id: authComboBox
            Kirigami.FormData.label: i18n("Authentication:")
            visible: securityCombobox.currentIndex === 2
                     || securityCombobox.currentIndex === 4
            model: [i18n("TLS"), i18n("LEAP"), i18n("FAST"), i18n(
                    "Tunneled TLS"), i18n(
                    "Protected EAP")] // more - SIM, AKA, PWD ?
        }
        Controls.Label {
            visible: securityCombobox.currentIndex !== 3 && securityCombobox.currentIndex !== 0
            text: "----Not yet implemented----"
            color: "red"
        }

        Kirigami.Separator {
            Kirigami.FormData.label: i18n("IP settings")
            Kirigami.FormData.isSection: true
        }

        Controls.ComboBox {
            id: ipMethodCombobox
            model: [i18n("Automatic"), i18n("Manual")]
            currentIndex: ipSettings["method"] === "manual" ? 1 : 0
            property var manualIp: currentIndex === 1
            onCurrentIndexChanged: {
                ipSettings["method"] = currentIndex === 1 ? "manual" : "auto"
            }
        }

        Controls.TextField {
            id: manualIPaddress
            Kirigami.FormData.label: i18n("IP Address:")
            visible: ipMethodCombobox.manualIp
            placeholderText: "192.168.1.128"
            text: ipSettings["address"] ? ipSettings["address"] : ""
            onTextChanged: ipSettings["address"] = text
            validator: RegularExpressionValidator {
                regularExpression: ipRegex
            }
        }

        Controls.TextField {
            id: manualIPgateway
            Kirigami.FormData.label: i18n("Gateway:")
            visible: ipMethodCombobox.manualIp
            placeholderText: "192.168.1.1"
            text: ipSettings["gateway"] ? ipSettings["gateway"] : ""
            onTextChanged: ipSettings["gateway"] = text
            validator: RegularExpressionValidator {
                regularExpression: ipRegex
            }
        }

        Controls.TextField {
            id: manualIPprefix
            Kirigami.FormData.label: i18n("Network prefix length:")
            visible: ipMethodCombobox.manualIp
            placeholderText: "16"
            text: ipSettings["prefix"] ? ipSettings["prefix"] : ""
            onTextChanged: ipSettings["prefix"] = text
            validator: IntValidator {
                bottom: 1
                top: 32
            }
        }

        Controls.TextField {
            id: manualIPdns
            Kirigami.FormData.label: i18n("DNS:")
            visible: ipMethodCombobox.manualIp
            placeholderText: "8.8.8.8"
            text: ipSettings["dns"] ? ipSettings["dns"] : ""
            onTextChanged: ipSettings["dns"] = text
            validator: RegularExpressionValidator {
                regularExpression: ipRegex
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
