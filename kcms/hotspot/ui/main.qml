// SPDX-FileCopyrightText: 2020 Tobias Fella <fella@posteo.de>
// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls

import org.kde.plasma.networkmanagement as PlasmaNM
import org.kde.kirigami as Kirigami
import org.kde.kcm
import org.kde.kirigamiaddons.labs.mobileform as MobileForm

SimpleKCM {
    id: root

    leftPadding: 0
    rightPadding: 0
    topPadding: Kirigami.Units.gridUnit
    bottomPadding: Kirigami.Units.gridUnit

    ColumnLayout {
        spacing: 0
        width: root.width

        PlasmaNM.Handler {
            id: handler
        }

        PlasmaNM.WirelessStatus {
            id: wirelessStatus
        }

        MobileForm.FormCard {
            Layout.fillWidth: true

            contentItem: ColumnLayout {
                spacing: 0

                MobileForm.FormSwitchDelegate {
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
        }

        MobileForm.FormCard {
            Layout.fillWidth: true
            Layout.topMargin: Kirigami.Units.largeSpacing

            contentItem: ColumnLayout {
                spacing: 0

                MobileForm.FormTextFieldDelegate {
                    label: i18n("Hotspot SSID")
                    enabled: !hotspotToggle.checked
                    text: PlasmaNM.Configuration.hotspotName
                    onTextChanged: PlasmaNM.Configuration.hotspotName = text
                }

                MobileForm.FormDelegateSeparator {}

                MobileForm.FormTextFieldDelegate {
                    label: i18n("Hotspot Password")
                    enabled: !hotspotToggle.checked
                    echoMode: TextInput.Password
                    text: PlasmaNM.Configuration.hotspotPassword
                    onTextChanged: PlasmaNM.Configuration.hotspotPassword = text
                }
            }
        }
    }
}
