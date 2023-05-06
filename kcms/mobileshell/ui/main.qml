/*
 * SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
 * SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15 as QQC2

import org.kde.kirigami 2.19 as Kirigami
import org.kde.kcm 1.3 as KCM
import org.kde.kirigamiaddons.labs.mobileform 0.1 as MobileForm
import org.kde.plasma.private.mobileshell.shellsettingsplugin as ShellSettings

KCM.SimpleKCM {
    id: root

    title: i18n("Shell")

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
                
                MobileForm.FormCardHeader {
                    title: i18n("General")
                }
                
                MobileForm.FormButtonDelegate {
                    id: shellVibrationsButton
                    text: i18n("Shell Vibrations")
                    onClicked: kcm.push("VibrationForm.qml")
                }
                
                MobileForm.FormDelegateSeparator { above: shellVibrationsButton; below: animationsSwitch }
                
                MobileForm.FormSwitchDelegate {
                    id: animationsSwitch
                    text: i18n("Animations")
                    description: i18n("If this is off, animations will be reduced as much as possible.")
                    checked: ShellSettings.Settings.animationsEnabled
                    onCheckedChanged: {
                        if (checked != ShellSettings.Settings.animationsEnabled) {
                            ShellSettings.Settings.animationsEnabled = checked;
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
                    title: i18n("Navigation Panel")
                }
                
                MobileForm.FormSwitchDelegate {
                    id: gestureDelegate
                    text: i18n("Gesture-only Mode")
                    description: i18n("Whether to hide the navigation panel.")
                    checked: !ShellSettings.Settings.navigationPanelEnabled
                    onCheckedChanged: {
                        if (checked != !ShellSettings.Settings.navigationPanelEnabled) {
                            ShellSettings.Settings.navigationPanelEnabled = !checked;
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
                    title: i18n("Task Switcher")
                }
                
                MobileForm.FormSwitchDelegate {
                    text: i18n("Show Application Previews")
                    description: i18n("Turning this off may help improve performance.")
                    checked: ShellSettings.Settings.taskSwitcherPreviewsEnabled
                    onCheckedChanged: {
                        if (checked != ShellSettings.Settings.taskSwitcherPreviewsEnabled) {
                            ShellSettings.Settings.taskSwitcherPreviewsEnabled = checked;
                        }
                    }
                }
            }
        }
        
        MobileForm.FormCard {
            Layout.fillWidth: true
            Layout.topMargin: Kirigami.Units.largeSpacing
            
            contentItem: ColumnLayout {
                id: parentCol
                spacing: 0
                
                MobileForm.FormCardHeader {
                    title: i18n("Action Drawer")
                }
                
                MobileForm.FormButtonDelegate {
                    id: quickSettingsButton
                    text: i18n("Quick Settings")
                    onClicked: kcm.push("QuickSettingsForm.qml")
                }
                
                MobileForm.FormDelegateSeparator { above: quickSettingsButton; below: topLeftActionDrawerModeDelegate }
                
                property string pinnedString: i18nc("Pinned action drawer mode", "Pinned Mode")
                property string expandedString: i18nc("Expanded action drawer mode", "Expanded Mode")
                
                MobileForm.FormComboBoxDelegate {
                    id: topLeftActionDrawerModeDelegate
                    text: i18n("Top Left Drawer Mode")
                    description: i18n("Mode when opening from the top left.")
                    
                    currentIndex: indexOfValue(ShellSettings.Settings.actionDrawerTopLeftMode)
                    model: ListModel {
                        // we can't use i18n with ListElement
                        Component.onCompleted: {
                            append({"name": parentCol.pinnedString, "value": ShellSettings.Settings.Pinned});
                            append({"name": parentCol.expandedString, "value": ShellSettings.Settings.Expanded});
                            
                            // indexOfValue doesn't bind to model changes unfortunately, set currentIndex manually here
                            topLeftActionDrawerModeDelegate.currentIndex = topLeftActionDrawerModeDelegate.indexOfValue(ShellSettings.Settings.actionDrawerTopLeftMode)
                        }
                    }
                    
                    textRole: "name"
                    valueRole: "value"
                    
                    Component.onCompleted: dialog.parent = root
                    onCurrentValueChanged: ShellSettings.Settings.actionDrawerTopLeftMode = currentValue
                }
                
                MobileForm.FormDelegateSeparator { above: topLeftActionDrawerModeDelegate; below: topRightActionDrawerModeDelegate }
                
                MobileForm.FormComboBoxDelegate {
                    id: topRightActionDrawerModeDelegate
                    text: i18n("Top Right Drawer Mode")
                    description: i18n("Mode when opening from the top right.")
                    
                    model: ListModel {
                        // we can't use i18n with ListElement
                        Component.onCompleted: {
                            append({"name": parentCol.pinnedString, "value": ShellSettings.Settings.Pinned});
                            append({"name": parentCol.expandedString, "value": ShellSettings.Settings.Expanded});

                            // indexOfValue doesn't bind to model changes unfortunately, set currentIndex manually here
                            topRightActionDrawerModeDelegate.currentIndex = topRightActionDrawerModeDelegate.indexOfValue(ShellSettings.Settings.actionDrawerTopRightMode)
                        }
                    }
                    
                    textRole: "name"
                    valueRole: "value"
                    
                    Component.onCompleted: {
                        dialog.parent = root
                    }
                    onCurrentValueChanged: ShellSettings.Settings.actionDrawerTopRightMode = currentValue
                }
            }
        }
    }
}
