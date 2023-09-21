// SPDX-FileCopyrightText: 2020 Tobias Fella <fella@posteo.de>
// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls

import org.kde.plasma.networkmanagement as PlasmaNM
import org.kde.kirigami as Kirigami
import org.kde.kcmutils
import org.kde.kirigamiaddons.formcard as FormCard

SimpleKCM {
    id: root

    leftPadding: 0
    rightPadding: 0
    topPadding: 0
    bottomPadding: 0

    data: [
        PlasmaNM.Handler {
            id: handler
        },

        PlasmaNM.WirelessStatus {
            id: wirelessStatus
        }
    ]

    ColumnLayout {
        spacing: 0

        FormCard.FormCard {
            Layout.topMargin: Kirigami.Units.gridUnit

            FormCard.FormSwitchDelegate {
                id: hotspotToggle
                text: i18n("Hotspot")
                description: i18n("Whether the wireless hotspot is enabled.");

                checked: wirelessStatus.hotspotSSID.length !== 0

                onToggled: {
                    if (hotspotToggle.checked) {
                        handler.createHotspot();
                    } else {
                        handler.stopHotspot();
                    }
                }
            }
        }

        FormCard.FormCard {
            Layout.topMargin: Kirigami.Units.gridUnit
            Layout.bottomMargin: Kirigami.Units.gridUnit

            FormCard.FormTextFieldDelegate {
                label: i18n("Hotspot SSID")
                enabled: !hotspotToggle.checked
                text: PlasmaNM.Configuration.hotspotName
                onTextChanged: PlasmaNM.Configuration.hotspotName = text
            }

            FormCard.FormDelegateSeparator {}

            FormCard.FormTextFieldDelegate {
                label: i18n("Hotspot Password")
                enabled: !hotspotToggle.checked
                echoMode: TextInput.Password
                text: PlasmaNM.Configuration.hotspotPassword
                onTextChanged: PlasmaNM.Configuration.hotspotPassword = text
            }
        }
    }
}
