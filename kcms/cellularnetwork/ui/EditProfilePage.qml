// SPDX-FileCopyrightText: 2020-2022 Devin Lin <espidev@gmail.com>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick 2.12
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.12 as Controls

import org.kde.kirigami 2.19 as Kirigami
import org.kde.kirigamiaddons.formcard 1 as FormCard

import cellularnetworkkcm 1.0

FormCard.FormCardPage {
    id: editProfile
    title: profile != null ? i18n("Edit APN") : i18n("New APN")

    topPadding: Kirigami.Units.gridUnit
    bottomPadding: Kirigami.Units.gridUnit
    leftPadding: 0
    rightPadding: 0
    
    property Modem modem
    property ProfileSettings profile
    
    FormCard.FormCard {
        Layout.topMargin: Kirigami.Units.gridUnit
            
        FormCard.FormTextFieldDelegate {
            id: profileName
            label: i18n("Name")
            text: profile != null ? profile.name : ""
        }

        FormCard.FormDelegateSeparator { above: profileName; below: profileApn }

        FormCard.FormTextFieldDelegate {
            id: profileApn
            label: i18n("APN")
            text: profile != null ? profile.apn : ""
        }

        FormCard.FormDelegateSeparator { above: profileApn; below: profileUsername }

        FormCard.FormTextFieldDelegate {
            id: profileUsername
            label: i18n("Username")
            text: profile != null ? profile.user : ""
        }

        FormCard.FormDelegateSeparator { above: profileUsername; below: profilePassword }

        FormCard.FormTextFieldDelegate {
            id: profilePassword
            label: i18n("Password")
            text: profile != null ? profile.password : ""
        }

        FormCard.FormDelegateSeparator { above: profilePassword; below: profileNetworkType }

        FormCard.FormComboBoxDelegate {
            id: profileNetworkType
            text: i18n("Network type")
            model: [i18n("4G/3G/2G"), i18n("3G/2G"), i18n("2G"), i18n("Only 4G"), i18n("Only 3G"), i18n("Only 2G"), i18n("Any")]
            Component.onCompleted: {
                if (profile != null) {
                    currentIndex = indexOfValue(profile.networkType)
                }
            }
        }

        FormCard.FormDelegateSeparator { above: profileNetworkType; below: profileSave }

        FormCard.FormButtonDelegate {
            id: profileSave
            text: i18n("Save profile")
            icon.name: "document-save"
            onClicked: {
                if (profile == null) { // create new profile
                    modem.addProfile(profileName.text, profileApn.text, profileUsername.text, profilePassword.text, profileNetworkType.currentText);
                } else { // edit existing profile
                    modem.updateProfile(profile.connectionUni, profileName.text, profileApn.text, profileUsername.text, profilePassword.text, profileNetworkType.currentText);
                }
                kcm.pop()
            }
        }
    }
}
