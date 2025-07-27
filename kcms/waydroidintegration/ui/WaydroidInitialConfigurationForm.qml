/*
 * SPDX-FileCopyrightText: 2025 Florian RICHER <florian.richer@protonmail.com>
 * SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15 as QQC2

import org.kde.kirigami 2.19 as Kirigami
import org.kde.kirigamiaddons.formcard 1.0 as FormCard
import org.kde.plasma.components 3.0 as PC3
import org.kde.plasma.private.mobileshell.waydroidintegrationplugin as AIP

ColumnLayout {
    FormCard.FormHeader {
        title: i18n("Initial configuration")
    }

    FormCard.FormCard {
        FormCard.FormComboBoxDelegate {
            id: systemType
            text: i18n("System type")

            model: [
                {"name": "Vanilla", "value": AIP.WaydroidState.Vanilla},
                {"name": "GAPPS", "value": AIP.WaydroidState.Gapps}
            ]

            textRole: "name"
            valueRole: "value"
        }
    }

    PC3.Button {
        text: i18n("Configure waydroid")
        Layout.alignment: Qt.AlignHCenter
        enabled: systemType.currentValue !== undefined

        onClicked: AIP.WaydroidState.initialize(systemType.currentValue, AIP.WaydroidState.Lineage)
    }
}