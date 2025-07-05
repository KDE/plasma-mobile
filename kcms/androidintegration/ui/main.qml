/*
 * SPDX-FileCopyrightText: 2025 Florian RICHER <florian.richer@protonmail.com>
 * SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15 as QQC2

import org.kde.kirigami 2.19 as Kirigami
import org.kde.kcmutils as KCM
import org.kde.kirigamiaddons.formcard 1.0 as FormCard
import org.kde.plasma.components 3.0 as PC3
import org.kde.plasma.private.mobileshell.androidintegrationplugin as AIP

KCM.SimpleKCM {
    id: root

    title: i18n("Android Integration")

    topPadding: 0
    bottomPadding: 0
    leftPadding: 0
    rightPadding: 0

    ColumnLayout {
        visible: AIP.WaydroidState.status == AIP.WaydroidState.NotSupported
        anchors.centerIn: parent
        spacing: Kirigami.Units.largeSpacing

        QQC2.Label {
            text: i18n("Waydroid is not installed")
        }

        PC3.Button {
            text: i18n("Check installation")
            Layout.alignment: Qt.AlignHCenter
            onClicked: AIP.WaydroidState.checkSupports()
        }
    }

    ColumnLayout {
        visible: AIP.WaydroidState.status == AIP.WaydroidState.NotInitialized

        FormCard.FormHeader {
            title: i18n("Initial configuration")
        }

        FormCard.FormCard {
            FormCard.FormComboBoxDelegate {
                id: systemType
                text: i18n("System type")

                model: [
                    {"name": "Vanilla", "value": AIP.WaydroidState.Vanilla},
                    {"name": "FOSS", "value": AIP.WaydroidState.Foss},
                    {"name": "GAPPS", "value": AIP.WaydroidState.Gapps}
                ]

                textRole: "name"
                valueRole: "value"
            }

            FormCard.FormDelegateSeparator { above: systemType; below: romType }

            FormCard.FormComboBoxDelegate {
                id: romType
                text: i18n("ROM type")

                model: [
                    {"name": "Lineage", "value": AIP.WaydroidState.Lineage},
                    {"name": "Bliss", "value": AIP.WaydroidState.Bliss}
                ]

                textRole: "name"
                valueRole: "value"
            }

        }

        PC3.Button {
            text: i18n("Configure waydroid")
            Layout.alignment: Qt.AlignHCenter
            enabled: systemType.currentValue !== undefined && romType.currentValue !== undefined

            onClicked: AIP.WaydroidState.initialize(systemType.currentValue, romType.currentValue)
        }
    }

    ColumnLayout {
        visible: AIP.WaydroidState.status == AIP.WaydroidState.Initialiazing
        anchors.centerIn: parent
        spacing: Kirigami.Units.largeSpacing

        PC3.BusyIndicator {
            Layout.alignment: Qt.AlignHCenter
            implicitHeight: Kirigami.Units.iconSizes.huge
            implicitWidth: Kirigami.Units.iconSizes.huge

            Kirigami.Theme.inherit: false
            Kirigami.Theme.colorSet: Kirigami.Theme.Complementary
        }

        QQC2.Label {
            text: i18n("Waydroid is initializing.\nIt can take a few minutes.")
        }
    }

    ColumnLayout {
        visible: AIP.WaydroidState.status == AIP.WaydroidState.Initialized

        FormCard.FormHeader {
            title: i18n("Configuration")
        }
    }

    ColumnLayout {
        visible: AIP.WaydroidState.status == AIP.WaydroidState.FailedToInitialize
        anchors.centerIn: parent
        spacing: Kirigami.Units.largeSpacing

        QQC2.Label {
            text: i18n("Failed to initialize Waydroid.")
        }

        PC3.Button {
            text: i18n("Go back")
            Layout.alignment: Qt.AlignHCenter
            onClicked: AIP.WaydroidState.checkSupports()
        }
    }
}