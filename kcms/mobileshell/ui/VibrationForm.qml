/*
 * SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
 * SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15 as QQC2

import org.kde.kirigami 2.19 as Kirigami
import org.kde.kcmutils as KCM
import org.kde.kirigamiaddons.labs.mobileform 0.1 as MobileForm
import org.kde.plasma.private.mobileshell.shellsettingsplugin as ShellSettings

Kirigami.ScrollablePage {
    id: root
    title: i18n("Shell Vibrations")
    leftPadding: 0
    rightPadding: 0
    topPadding: Kirigami.Units.gridUnit
    bottomPadding: Kirigami.Units.gridUnit
    
    ColumnLayout {
        spacing: 0
        width: root.width
        
        MobileForm.FormCard {
            Layout.fillWidth: true
            
            contentItem: ColumnLayout {
                spacing: 0
                
                MobileForm.FormSwitchDelegate {
                    id: shellVibrationsSwitch
                    text: i18n("Shell Vibrations")
                    description: i18n("Whether to have vibrations enabled in the shell.")
                    checked: ShellSettings.Settings.vibrationsEnabled
                    onCheckedChanged: {
                        if (checked != ShellSettings.Settings.vibrationsEnabled) {
                            ShellSettings.Settings.vibrationsEnabled = checked;
                        }
                    }
                }
                
                MobileForm.FormDelegateSeparator { above: shellVibrationsSwitch; below: vibrationIntensityDelegate }
                
                MobileForm.FormComboBoxDelegate {
                    id: vibrationIntensityDelegate
                    text: i18n("Vibration Intensity")
                    description: i18n("How intense shell vibrations should be.")
                    
                    property string lowIntensityString: i18nc("Low intensity", "Low")
                    property string mediumIntensityString: i18nc("Medium intensity", "Medium")
                    property string highIntensityString: i18nc("High intensity", "High")
                    
                    currentIndex: indexOfValue(ShellSettings.Settings.vibrationIntensity)
                    model: ListModel {
                        // we can't use i18n with ListElement
                        Component.onCompleted: {
                            append({"name": vibrationIntensityDelegate.highIntensityString, "value": 1.0});
                            append({"name": vibrationIntensityDelegate.mediumIntensityString, "value": 0.5});
                            append({"name": vibrationIntensityDelegate.lowIntensityString, "value": 0.2});
                            
                            // indexOfValue doesn't bind to model changes unfortunately, set currentIndex manually here
                            vibrationIntensityDelegate.currentIndex = vibrationIntensityDelegate.indexOfValue(ShellSettings.Settings.vibrationIntensity)
                        }
                    }
                    
                    textRole: "name"
                    valueRole: "value"
                    
                    Component.onCompleted: dialog.parent = root
                    onCurrentValueChanged: ShellSettings.Settings.vibrationIntensity = currentValue;
                }
                
                MobileForm.FormDelegateSeparator { above: vibrationIntensityDelegate; below: vibrationDurationDelegate }
                
                MobileForm.FormComboBoxDelegate {
                    id: vibrationDurationDelegate
                    text: i18n("Vibration Duration")
                    description: i18n("How long shell vibrations should be.")
                    
                    property string longString: i18nc("Long duration", "Long")
                    property string mediumString: i18nc("Medium duration", "Medium")
                    property string shortString: i18nc("Short duration", "Short")
                    
                    currentIndex: indexOfValue(ShellSettings.Settings.vibrationDuration)
                    model: ListModel {
                        // we can't use i18n with ListElement
                        Component.onCompleted: {
                            append({"name": vibrationDurationDelegate.longString, "value": 100});
                            append({"name": vibrationDurationDelegate.mediumString, "value": 50});
                            append({"name": vibrationDurationDelegate.shortString, "value": 15});
                            
                            // indexOfValue doesn't bind to model changes unfortunately, set currentIndex manually here
                            vibrationDurationDelegate.currentIndex = vibrationDurationDelegate.indexOfValue(ShellSettings.Settings.vibrationDuration)
                        }
                    }
                    
                    textRole: "name"
                    valueRole: "value"
                    
                    Component.onCompleted: dialog.parent = root
                    onCurrentValueChanged: ShellSettings.Settings.vibrationDuration = currentValue;
                }
            }
        }
        
        MobileForm.FormSectionText {
            text: i18n("Keyboard vibrations are controlled separately in the keyboard settings module.")
        }
    }
}
