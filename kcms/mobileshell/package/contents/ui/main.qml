/*
 * SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
 * SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15 as QQC2

import org.kde.kirigami 2.19 as Kirigami
import org.kde.kcm 1.3 as KCM
import org.kde.plasma.private.mobileshell 1.0 as MobileShell
import org.kde.kirigamiaddons.labs.mobileform 0.1 as MobileForm

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
                    checked: MobileShell.MobileShellSettings.animationsEnabled
                    onCheckedChanged: {
                        if (checked != MobileShell.MobileShellSettings.animationsEnabled) {
                            MobileShell.MobileShellSettings.animationsEnabled = checked;
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
                    checked: !MobileShell.MobileShellSettings.navigationPanelEnabled
                    onCheckedChanged: {
                        if (checked != !MobileShell.MobileShellSettings.navigationPanelEnabled) {
                            MobileShell.MobileShellSettings.navigationPanelEnabled = !checked;
                        }
                    }
                }
                
                MobileForm.FormDelegateSeparator { 
                    visible: MobileShell.MobileShellSettings.navigationPanelEnabled
                    above: gestureDelegate
                    below: keyboardButtonDelegate 
                }
                
                MobileForm.FormSwitchDelegate {
                    id: keyboardButtonDelegate
                    visible: MobileShell.MobileShellSettings.navigationPanelEnabled
                    text: i18n("Keyboard Toggle")
                    description: i18n("Whether to show a keyboard button on the navigation panel.")
                    checked: MobileShell.MobileShellSettings.keyboardButtonEnabled
                    onCheckedChanged: {
                        if (checked != MobileShell.MobileShellSettings.keyboardButtonEnabled) {
                            MobileShell.MobileShellSettings.keyboardButtonEnabled = checked;
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
                    checked: MobileShell.MobileShellSettings.taskSwitcherPreviewsEnabled
                    onCheckedChanged: {
                        if (checked != MobileShell.MobileShellSettings.taskSwitcherPreviewsEnabled) {
                            MobileShell.MobileShellSettings.taskSwitcherPreviewsEnabled = checked;
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
                    
                    currentValue: {
                        let mode = MobileShell.MobileShellSettings.actionDrawerTopLeftMode;
                        if (mode === MobileShell.MobileShellSettings.Expanded) {
                            return parentCol.expandedString;
                        } else{
                            return parentCol.pinnedString;
                        }
                    }
                    model: ListModel {
                        // we can't use i18n with ListElement
                        Component.onCompleted: {
                            append({"name": parentCol.pinnedString, "value": MobileShell.MobileShellSettings.Pinned});
                            append({"name": parentCol.expandedString, "value": MobileShell.MobileShellSettings.Expanded});
                        }
                    }
                    
                    Component.onCompleted: dialog.parent = root

                    dialogDelegate: QQC2.RadioDelegate {
                        implicitWidth: Kirigami.Units.gridUnit * 16
                        topPadding: Kirigami.Units.smallSpacing * 2
                        bottomPadding: Kirigami.Units.smallSpacing * 2
                        
                        text: name
                        checked: topLeftActionDrawerModeDelegate.currentValue === name
                        onCheckedChanged: {
                            if (checked) {
                                MobileShell.MobileShellSettings.actionDrawerTopLeftMode = value;
                            }
                        }
                    }
                }
                
                MobileForm.FormDelegateSeparator { above: topLeftActionDrawerModeDelegate; below: topRightActionDrawerModeDelegate }
                
                MobileForm.FormComboBoxDelegate {
                    id: topRightActionDrawerModeDelegate
                    text: i18n("Top Right Drawer Mode")
                    description: i18n("Mode when opening from from the top right.")
                    
                    currentValue: {
                        let mode = MobileShell.MobileShellSettings.actionDrawerTopRightMode;
                        if (mode === MobileShell.MobileShellSettings.Expanded) {
                            return parentCol.expandedString;
                        } else {
                            return parentCol.pinnedString;
                        }
                    }
                    model: ListModel {
                        // we can't use i18n with ListElement
                        Component.onCompleted: {
                            append({"name": parentCol.pinnedString, "value": MobileShell.MobileShellSettings.Pinned});
                            append({"name": parentCol.expandedString, "value": MobileShell.MobileShellSettings.Expanded});
                        }
                    }
                    Component.onCompleted: dialog.parent = root
                    dialogDelegate: QQC2.RadioDelegate {
                        implicitWidth: Kirigami.Units.gridUnit * 16
                        topPadding: Kirigami.Units.smallSpacing * 2
                        bottomPadding: Kirigami.Units.smallSpacing * 2
                        
                        text: name
                        checked: topRightActionDrawerModeDelegate.currentValue === name
                        onCheckedChanged: {
                            if (checked) {
                                MobileShell.MobileShellSettings.actionDrawerTopRightMode = value;
                            }
                        }
                    }
                }
            }
        }
    }
}
