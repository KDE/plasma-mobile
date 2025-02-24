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
        },

        Kirigami.PromptDialog {
            id: hotspotDialog
            title: i18n("Configure Hotspot")
            standardButtons: Kirigami.PromptDialog.Save | Kirigami.PromptDialog.Cancel

            onOpened: {
                hotspotSsidField.text = PlasmaNM.Configuration.hotspotName;
                hotspotPasswordField.text = PlasmaNM.Configuration.hotspotPassword;
            }

            onAccepted: {
                PlasmaNM.Configuration.hotspotName = hotspotSsidField.text;
                PlasmaNM.Configuration.hotspotPassword = hotspotPasswordField.text;

                // these properties need to be manually updated since they're not NOTIFYable
                hotspotSSIDText.description = PlasmaNM.Configuration.hotspotName;
                hotspotPasswordText.description = PlasmaNM.Configuration.hotspotPassword;
            }

            ColumnLayout {
                Controls.Label {
                    text: i18n('Hotspot SSID:')
                }
                Controls.TextField {
                    Layout.fillWidth: true
                    id: hotspotSsidField
                }
                Controls.Label {
                    text: i18n('Hotspot Password:')
                }
                Controls.TextField {
                    Layout.fillWidth: true
                    id: hotspotPasswordField
                }
            }
        }
    ]

    ColumnLayout {
        spacing: 0

        FormCard.FormCard {
            Layout.topMargin: Kirigami.Units.gridUnit

            FormCard.FormSwitchDelegate {
                id: hotspotToggle
                text: i18n("Hotspot")
                description: i18n("Share your internet connection with other devices as a Wi-Fi network.");

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

        FormCard.FormHeader {
            title: i18n("Settings")
        }

        FormCard.FormCard {
            FormCard.FormTextDelegate {
                id: hotspotSSIDText
                enabled: !hotspotToggle.checked
                text: i18n("Hotspot SSID")
                description: PlasmaNM.Configuration.hotspotName
            }

            FormCard.FormDelegateSeparator {}

            FormCard.FormTextDelegate {
                id: hotspotPasswordText
                enabled: !hotspotToggle.checked
                text: i18n("Hotspot Password")
                description: PlasmaNM.Configuration.hotspotPassword
            }

            FormCard.FormDelegateSeparator {}

            FormCard.FormButtonDelegate {
                enabled: !hotspotToggle.checked
                text: i18n('Configure')
                onClicked: hotspotDialog.open()
            }
        }
    }
}
