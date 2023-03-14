/*
    SPDX-FileCopyrightText: 2020 Tobias Fella <fella@posteo.de>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick 2.6
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.2 as Controls
import org.kde.plasma.networkmanagement 0.2 as PlasmaNM
import org.kde.kirigami 2.10 as Kirigami
import org.kde.kcm 1.2

SimpleKCM {

    PlasmaNM.Handler {
        id: handler
    }

    Kirigami.FormLayout {
        Controls.Switch {
            id: hotspotToggle
            Kirigami.FormData.label: i18n("Enabled:")
            onToggled: {
                if (hotspotToggle.checked) {
                    handler.createHotspot()
                } else {
                    handler.stopHotspot()
                }
            }
        }

        Controls.TextField {
            id: hotspotName
            Kirigami.FormData.label: i18n("SSID:")
            text: PlasmaNM.Configuration.hotspotName
        }

        Kirigami.PasswordField {
            id: hotspotPassword
            Kirigami.FormData.label: i18n("Password:")
            text: PlasmaNM.Configuration.hotspotPassword
        }

        Controls.Button {
            text: i18n("Save")
            onClicked: {
                PlasmaNM.Configuration.hotspotName = hotspotName.text
                PlasmaNM.Configuration.hotspotPassword = hotspotPassword.text
                if (hotspotToggle.checked) {
                    handler.stopHotspot()
                    handler.createHotspot()
                }
            }
        }
    }
}
