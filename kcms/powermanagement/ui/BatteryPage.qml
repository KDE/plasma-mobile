// SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
// SPDX-FileCopyrightText: 2023 Carl Schwan <carl@carlschwan.eu>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts

import org.kde.kirigami as Kirigami
import org.kde.plasma.components 3 as PlasmaComponents
import org.kde.kcmutils
import org.kde.kirigamiaddons.formcard 1 as FormCard
import org.kde.kcm.power.mobile.private

FormCard.FormCardPage {
    id: root

    property QtObject battery
    property string vendor
    property string product
    property string currentUdi

    title: i18n("Battery Information")

    data: HistoryModel {
        id: history

        duration: 86400 // last 24 hours
        device: currentUdi
        type: HistoryModel.ChargeType
    }

    FormCard.FormHeader {
        title: i18n("Usage Graph")
        visible: history.count > 1
    }

    FormCard.FormCard {
        visible: history.count > 1

        FormCard.AbstractFormDelegate {
            background: null
            clip: true

            contentItem: Flickable {
                implicitWidth: 500
                implicitHeight: 200
                contentWidth: 500
                contentHeight: 200

                Graph {
                    id: graph
                    width: 500
                    height: 200
                    implicitWidth: 500
                    implicitHeight: 200
                    data: history.points

                    // Set grid lines distances which directly correspondent to the xTicksAt variables
                    readonly property var xDivisionWidths: [1000 * 60 * 10, 1000 * 60 * 60 * 12, 1000 * 60 * 60, 1000 * 60 * 30, 1000 * 60 * 60 * 2, 1000 * 60 * 10]
                    xTicksAt: graph.xTicksAtFullSecondHour
                    xDivisionWidth: xDivisionWidths[xTicksAt]

                    xMin: history.firstDataPointTime
                    xMax: history.lastDataPointTime
                    xDuration: history.duration

                    yMax: 100
                    yStep: 20
                    visible: history.count > 1
                }
            }
        }
    }

    FormCard.FormHeader {
        title: i18n("Information")
    }

    FormCard.FormCard {
        FormCard.FormTextDelegate {
            id: isRechargeableDelegate
            text: i18n("Is Rechargeable")
            description: battery.rechargeable ? i18n("Yes") : i18n("No")
        }

        FormCard.FormDelegateSeparator {}

        FormCard.FormTextDelegate {
            id: chargeStateDelegate
            text: i18n("Charge State")
            description: {
                switch (battery.chargeState) {
                    case Battery.NoCharge: return i18n("Not charging")
                    case Battery.Charging: return i18n("Charging")
                    case Battery.Discharging: return i18n("Discharging")
                    case Battery.FullyCharged: return i18n("Fully charged")
                    default: return i18n("Unknown")
                }
            }
        }

        FormCard.FormDelegateSeparator {}

        FormCard.FormTextDelegate {
            id: currentChargeDelegate
            text: i18n("Current Charge")
            description: i18nc("%1 is percentage value", "%1 %", Number(battery.chargePercent).toLocaleString(Qt.locale(), "f", 0))
        }

        FormCard.FormDelegateSeparator {}

        FormCard.FormTextDelegate {
            id: healthDelegate
            text: i18n("Health")
            description: i18nc("%1 is percentage value", "%1 %", Number(battery.capacity).toLocaleString(Qt.locale(), "f", 0))
        }

        FormCard.FormDelegateSeparator {}

        FormCard.FormTextDelegate {
            id: vendorDelegate
            text: i18n("Vendor")
            description: root.vendor
        }

        FormCard.FormDelegateSeparator {}

        FormCard.FormTextDelegate {
            id: modelDelegate
            text: i18n("Model")
            description: root.product
        }

        FormCard.FormDelegateSeparator {}

        FormCard.FormTextDelegate {
            id: serialDelegate
            text: i18n("Serial Number")
            description: battery.serial
        }

        FormCard.FormDelegateSeparator {}

        FormCard.FormTextDelegate {
            id: technologyDelegate
            text: i18n("Technology")
            description: {
                switch (battery.technology) {
                    case Battery.LithiumIon: return i18n("Lithium ion")
                    case Battery.LithiumPolymer: return i18n("Lithium polymer")
                    case Battery.LithiumIronPhosphate: return i18n("Lithium iron phosphate")
                    case Battery.LeadAcid: return i18n("Lead acid")
                    case Battery.NickelCadmium: return i18n("Nickel cadmium")
                    case Battery.NickelMetalHydride: return i18n("Nickel metal hydride")
                    default: return i18n("Unknown technology")
                }
            }
        }
    }
}
