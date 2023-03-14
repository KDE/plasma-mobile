/*
    SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick 2.2
import QtQuick.Controls 2.10 as QQC2
import QtQuick.Layouts 1.11

import org.kde.kirigami 2.10 as Kirigami
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kcm 1.2
import org.kde.kirigamiaddons.labs.mobileform 0.1 as MobileForm
import org.kde.kcm.power.mobile.private 1.0

Kirigami.ScrollablePage {
    id: root
    
    property QtObject battery
    property string vendor
    property string product
    property string currentUdi
    
    title: i18n("Battery Information")
    
    leftPadding: 0
    rightPadding: 0
    topPadding: Kirigami.Units.gridUnit
    bottomPadding: Kirigami.Units.gridUnit
    
    HistoryModel {
        id: history
        duration: 86400 // last 24 hours
        device: currentUdi
        type: HistoryModel.ChargeType
    }

    ColumnLayout {
        width: parent.width
        spacing: 0
        
        MobileForm.FormCard {
            Layout.fillWidth: true
            
            contentItem: ColumnLayout {
                spacing: 0
                
                MobileForm.FormCardHeader {
                    title: i18n("Usage Graph")
                }
                
                MobileForm.AbstractFormDelegate {
                    Layout.fillWidth: true
                    background: Item {}
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
                
                            yUnits: i18nc("literal percent sign","%")
                            yMax: 100
                            yStep: 20
                            visible: history.count > 1
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
                
                MobileForm.FormCardHeader {
                    title: i18n("Information")
                }
                
                MobileForm.FormTextDelegate {
                    id: isRechargeableDelegate
                    text: i18n("Is Rechargeable")
                    description: battery.rechargeable ? i18n("Yes") : i18n("No")
                }
                
                MobileForm.FormDelegateSeparator {}
                
                MobileForm.FormTextDelegate {
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
                
                MobileForm.FormDelegateSeparator {}
                
                MobileForm.FormTextDelegate {
                    id: currentChargeDelegate
                    text: i18n("Current Charge")
                    description: i18nc("%1 is value, %2 is unit", "%1 %2", Number(battery.chargePercent).toLocaleString(Qt.locale(), "f", 0), i18n("%"))
                }
                
                MobileForm.FormDelegateSeparator {}
                
                MobileForm.FormTextDelegate {
                    id: healthDelegate
                    text: i18n("Health")
                    description: i18nc("%1 is value, %2 is unit", "%1 %2", Number(battery.capacity).toLocaleString(Qt.locale(), "f", 0), i18n("%"))
                }
                
                MobileForm.FormDelegateSeparator {}
                
                MobileForm.FormTextDelegate {
                    id: vendorDelegate
                    text: i18n("Vendor")
                    description: root.vendor
                }
                
                MobileForm.FormDelegateSeparator {}
                
                MobileForm.FormTextDelegate {
                    id: modelDelegate
                    text: i18n("Model")
                    description: root.product
                }
                
                MobileForm.FormDelegateSeparator {}
                
                MobileForm.FormTextDelegate {
                    id: serialDelegate
                    text: i18n("Serial Number")
                    description: battery.serial
                }
                
                MobileForm.FormDelegateSeparator {}
                
                MobileForm.FormTextDelegate {
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
    }
}
