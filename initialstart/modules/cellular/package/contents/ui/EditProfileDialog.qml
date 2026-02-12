// SPDX-FileCopyrightText: 2020-2023 Devin Lin <espidev@gmail.com>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick 2.12
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.12 as Controls

import org.kde.kirigami 2.19 as Kirigami

import org.kde.plasma.networkmanagement.cellular as Cellular

Kirigami.Dialog {
    id: dialog
    title: editConnectionUni ? i18n("Edit APN") : i18n("Add APN")
    clip: true

    property Cellular.CellularModem modem
    property string editConnectionUni: ""

    // Look up the profile data from the model when editing
    property int _profileIndex: modem && editConnectionUni ? modem.profiles.indexOfConnection(editConnectionUni) : -1

    standardButtons: Controls.Dialog.Ok | Controls.Dialog.Cancel

    onOpened: {
        if (_profileIndex >= 0) {
            let idx = modem.profiles.index(_profileIndex, 0);
            profileName.text = modem.profiles.data(idx, Cellular.CellularConnectionProfile.ConnectionName) ?? "";
            profileApn.text = modem.profiles.data(idx, Cellular.CellularConnectionProfile.ConnectionAPN) ?? "";
            profileUsername.text = modem.profiles.data(idx, Cellular.CellularConnectionProfile.ConnectionUser) ?? "";
            profilePassword.text = modem.profiles.data(idx, Cellular.CellularConnectionProfile.ConnectionPassword) ?? "";
            let nt = modem.profiles.data(idx, Cellular.CellularConnectionProfile.ConnectionNetworkType) ?? "";
            profileNetworkType.currentIndex = profileNetworkType.indexOfValue(nt);
        } else {
            profileName.text = "";
            profileApn.text = "";
            profileUsername.text = "";
            profilePassword.text = "";
            profileNetworkType.currentIndex = 0;
        }
    }

    onAccepted: {
        if (!editConnectionUni) {
            modem.addProfile(profileName.text, profileApn.text, profileUsername.text, profilePassword.text, profileNetworkType.currentValue);
        } else {
            modem.updateProfile(editConnectionUni, profileName.text, profileApn.text, profileUsername.text, profilePassword.text, profileNetworkType.currentValue);
        }
    }
    preferredWidth: Kirigami.Units.gridUnit * 20
    padding: Kirigami.Units.gridUnit

    ColumnLayout {
        Kirigami.FormLayout {
            Layout.fillWidth: true
            wideMode: false

            Controls.TextField {
                id: profileName
                Kirigami.FormData.label: i18n("Name")
            }
            Controls.TextField {
                id: profileApn
                Kirigami.FormData.label: i18n("APN")
            }
            Controls.TextField {
                id: profileUsername
                Kirigami.FormData.label: i18n("Username")
            }
            Controls.TextField {
                id: profilePassword
                Kirigami.FormData.label: i18n("Password")
            }
            Controls.ComboBox {
                id: profileNetworkType
                Kirigami.FormData.label: i18n("Network type")
                model: [i18n("4G/3G/2G"), i18n("3G/2G"), i18n("2G"), i18n("Only 4G"), i18n("Only 3G"), i18n("Only 2G"), i18n("Any")]
            }
        }
    }
}
