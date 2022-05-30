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

import "mobileform" as MobileForm

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
                
                Kirigami.Separator {
                    Layout.leftMargin: Kirigami.Units.largeSpacing
                    Layout.rightMargin: Kirigami.Units.largeSpacing
                    Layout.fillWidth: true
                    opacity: (!shellVibrationsButton.controlHovered && !animationsSwitch.controlHovered) ? 0.5 : 0
                }
                
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
                    text: i18n("Gesture-only Mode")
                    description: i18n("Whether to hide the navigation panel.")
                    checked: !MobileShell.MobileShellSettings.navigationPanelEnabled
                    onCheckedChanged: {
                        if (checked != !MobileShell.MobileShellSettings.navigationPanelEnabled) {
                            MobileShell.MobileShellSettings.navigationPanelEnabled = !checked;
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
                spacing: 0
                
                MobileForm.FormCardHeader {
                    title: i18n("Action Drawer")
                }
                
                MobileForm.FormButtonDelegate {
                    id: quickSettingsButton
                    text: i18n("Quick Settings")
                    onClicked: kcm.push("QuickSettingsForm.qml")
                }
            }
        }
    }
}
