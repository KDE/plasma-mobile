/*
    SPDX-FileCopyrightText: 2011 Sebastian Kügler <sebas@kde.org>
    SPDX-FileCopyrightText: 2012 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2015 Kai Uwe Broulik <kde@privat.broulik.de>
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

SimpleKCM {
    id: powermanagementModule
    
    leftPadding: 0
    rightPadding: 0
    topPadding: Kirigami.Units.gridUnit
    bottomPadding: Kirigami.Units.gridUnit

    ColumnLayout {
        width: parent.width
        spacing: 0
        
        MobileForm.FormCard {
            Layout.fillWidth: true
            
            contentItem: ColumnLayout {
                spacing: 0
                
                MobileForm.FormCardHeader {
                    title: i18n("Devices")
                }
                
                Repeater {
                    model: kcm.batteries
                    
                    delegate: MobileForm.AbstractFormDelegate {
                        Layout.fillWidth: true
                        
                        onClicked: kcm.push("BatteryPage.qml", { "battery": model.battery, "vendor": model.vendor, "product": model.product, "currentUdi": model.udi })
                        
                        contentItem: RowLayout {
                            spacing: Kirigami.Units.gridUnit
                            
                            Kirigami.Icon {
                                implicitWidth: Kirigami.Units.iconSizes.smallMedium
                                implicitHeight: Kirigami.Units.iconSizes.smallMedium
                                Layout.rightMargin: Kirigami.Units.largeSpacing
                                source: {
                                    switch (model.battery.type) {
                                        case 3: return model.battery.chargeState === 1 ? "battery-full-charging" : "battery-full"
                                        case 2: return "battery-ups"
                                        case 9: return "monitor"
                                        case 4: return "input-mouse"
                                        case 5: return "input-keyboard"
                                        case 1: return "phone"
                                        case 7: return "smartphone"
                                        default: return "paint-unknown"
                                    }
                                }
                            }
                            
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: Kirigami.Units.smallSpacing
                                
                                QQC2.Label {
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                    wrapMode: Text.Wrap
                                    maximumLineCount: 2
                                    color: Kirigami.Theme.textColor
                                    text: {
                                        let batteryType;
                                        switch (model.battery.type) {
                                            case 3: batteryType = i18n("Internal battery"); break;
                                            case 2: batteryType = i18n("UPS battery"); break;
                                            case 9: batteryType = i18n("Monitor battery"); break;
                                            case 4: batteryType = i18n("Mouse battery"); break;
                                            case 5: batteryType = i18n("Keyboard battery"); break;
                                            case 1: batteryType = i18n("PDA battery"); break;
                                            case 7: batteryType = i18n("Phone battery"); break;
                                            default: batteryType = i18n("Unknown battery"); break;
                                        }
                                        
                                        const chargePercent = i18nc("%1 is value, %2 is unit", "%1%2", Number(battery.chargePercent).toLocaleString(Qt.locale(), "f", 0), i18n("%"));
                                        
                                        return (model.battery.chargeState === Battery.Charging) ? i18nc("%1 is battery type, %2 is charge percent", "%1 %2 (Charging)", batteryType, chargePercent) : i18nc("%1 is battery type, %2 is charge percent", "%1 %2", batteryType, chargePercent);
                                    }
                                }
                                
                                QQC2.ProgressBar {
                                    Layout.fillWidth: true
                                    from: 0
                                    to: 100
                                    value: model.battery.chargePercent
                                }
                            }

                            Kirigami.Icon {
                                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                                source: "arrow-right"
                                implicitWidth: Math.round(Kirigami.Units.iconSizes.small * 0.75)
                                implicitHeight: Math.round(Kirigami.Units.iconSizes.small * 0.75)
                            }
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
                    title: i18n("Screen")
                }

                MobileForm.FormComboBoxDelegate {
                    id: dimScreenCombo
                    text: i18nc("Part of a sentence like 'Dim screen after 5 minutes'", "Dim screen after")
                    model: kcm.timeOptions()
                    currentIndex: kcm.dimScreenIdx
                    Component.onCompleted: dialog.parent = powermanagementModule
                    onCurrentIndexChanged: kcm.dimScreenIdx = currentIndex
                }

                MobileForm.FormDelegateSeparator { above: dimScreenCombo; below: screenOffCombo }

                MobileForm.FormComboBoxDelegate {
                    id: screenOffCombo
                    text: i18nc("Part of a sentence like 'Turn off screen after 5 minutes'", "Turn off screen after")
                    model: kcm.timeOptions()
                    currentIndex: kcm.screenOffIdx
                    Component.onCompleted: dialog.parent = powermanagementModule
                    onCurrentIndexChanged: kcm.screenOffIdx = currentIndex
                }

                MobileForm.FormDelegateSeparator { above: screenOffCombo; below: suspendCombo }

                MobileForm.FormComboBoxDelegate {
                    id: suspendCombo
                    text: i18nc("Part of a sentence like 'Suspend device after 5 minutes'", "Suspend device after")
                    model: kcm.timeOptions()
                    currentIndex: kcm.suspendSessionIdx
                    Component.onCompleted: dialog.parent = powermanagementModule
                    onCurrentIndexChanged: kcm.suspendSessionIdx = currentIndex
                }
            }
        }
    }
}
