/*
 * SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
 * SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15 as QQC2

import org.kde.kirigami 2.19 as Kirigami
import org.kde.kcmutils as KCM
import org.kde.kirigamiaddons.formcard 1.0 as FormCard
import org.kde.plasma.private.mobileshell.shellsettingsplugin as ShellSettings

KCM.SimpleKCM {
    id: root

    title: i18n("Shell")

    topPadding: 0
    bottomPadding: 0
    leftPadding: 0
    rightPadding: 0

    ColumnLayout {
        FormCard.FormHeader {
            title: i18n("General")
        }

        FormCard.FormCard {
            FormCard.FormButtonDelegate {
                id: shellVibrationsButton
                text: i18n("Shell Vibrations")
                onClicked: kcm.push("VibrationForm.qml")
            }

            FormCard.FormDelegateSeparator { above: shellVibrationsButton; below: animationsSwitch }

            FormCard.FormSwitchDelegate {
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

        FormCard.FormHeader {
            title: i18n("Status Bar")
        }

        FormCard.FormCard {
            FormCard.FormSwitchDelegate {
                id: dateInStatusBar
                text: i18n("Date in status bar")
                description: i18n("If on, date will be shown next to the clock in the status bar.")
                checked: ShellSettings.Settings.dateInStatusBar
                onCheckedChanged: {
                    if (checked != ShellSettings.Settings.dateInStatusBar) {
                        ShellSettings.Settings.dateInStatusBar = checked;
                    }
                }
            }

            FormCard.FormDelegateSeparator { above: quickSettingsButton; below: topLeftActionDrawerModeDelegate }

            FormCard.FormComboBoxDelegate {
                id: statusBarScaleFactorDelegate

                property string tinyString: i18nc("Status bar height", "Tiny")
                property string smallString: i18nc("Status bar height", "Small")
                property string normalString: i18nc("Status bar height", "Normal")
                property string largeString: i18nc("Status bar height","Large")
                property string xlargeString: i18nc("Status bar height", "Very Large")


                text: i18n("Status Bar Size")
                description: i18n("Size of the top panel (needs restart).")

                currentIndex: indexOfValue(ShellSettings.Settings.statusBarScaleFactor)
                model: ListModel {
                    // We can't use i18n with ListElement, so use a property instead
                    Component.onCompleted: {
                        append({"name": statusBarScaleFactorDelegate.tinyString, "value": 1.0});
                        append({"name": statusBarScaleFactorDelegate.smallString, "value": 1.15});
                        append({"name": statusBarScaleFactorDelegate.normalString, "value": 1.25});
                        append({"name": statusBarScaleFactorDelegate.largeString, "value": 1.5});
                        append({"name": statusBarScaleFactorDelegate.xlargeString, "value": 2.0});

                        // indexOfValue doesn't bind to model changes unfortunately, set currentIndex manually here
                        statusBarScaleFactorDelegate.currentIndex = statusBarScaleFactorDelegate.indexOfValue(ShellSettings.Settings.statusBarScaleFactor)
                    }
                }

                textRole: "name"
                valueRole: "value"

                Component.onCompleted: dialog.parent = root
                onCurrentValueChanged: ShellSettings.Settings.statusBarScaleFactor = currentValue
            }

        }

        FormCard.FormHeader {
            title: i18n("Navigation Panel")
        }

        FormCard.FormCard {
            FormCard.FormSwitchDelegate {
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

            FormCard.FormDelegateSeparator { visible: keyboardToggleDelegate.visible; above: gestureDelegate; below: keyboardToggleDelegate }

            FormCard.FormSwitchDelegate {
                id: keyboardToggleDelegate
                visible: !gestureDelegate.checked
                text: i18n("Always show keyboard toggle")
                description: i18n("Whether to always show the keyboard toggle button on the navigation panel.")
                checked: ShellSettings.Settings.alwaysShowKeyboardToggleOnNavigationPanel
                onCheckedChanged: {
                    if (checked != ShellSettings.Settings.alwaysShowKeyboardToggleOnNavigationPanel) {
                        ShellSettings.Settings.alwaysShowKeyboardToggleOnNavigationPanel = checked;
                    }
                }
            }
        }

        FormCard.FormHeader {
            title: i18n("Action Drawer")
        }

        FormCard.FormCard {
            id: quickSettings

            property string pinnedString: i18nc("Pinned action drawer mode", "Pinned Mode")
            property string expandedString: i18nc("Expanded action drawer mode", "Expanded Mode")

            FormCard.FormButtonDelegate {
                id: quickSettingsButton
                text: i18n("Quick Settings")
                onClicked: kcm.push("QuickSettingsForm.qml")
            }

            FormCard.FormDelegateSeparator { above: quickSettingsButton; below: topLeftActionDrawerModeDelegate }

            FormCard.FormComboBoxDelegate {
                id: topLeftActionDrawerModeDelegate
                text: i18n("Top Left Drawer Mode")
                description: i18n("Mode when opening from the top left.")

                currentIndex: indexOfValue(ShellSettings.Settings.actionDrawerTopLeftMode)
                model: ListModel {
                    // we can't use i18n with ListElement
                    Component.onCompleted: {
                        append({"name": quickSettings.pinnedString, "value": ShellSettings.Settings.Pinned});
                        append({"name": quickSettings.expandedString, "value": ShellSettings.Settings.Expanded});

                        // indexOfValue doesn't bind to model changes unfortunately, set currentIndex manually here
                        topLeftActionDrawerModeDelegate.currentIndex = topLeftActionDrawerModeDelegate.indexOfValue(ShellSettings.Settings.actionDrawerTopLeftMode)
                    }
                }

                textRole: "name"
                valueRole: "value"

                Component.onCompleted: dialog.parent = root
                onCurrentValueChanged: ShellSettings.Settings.actionDrawerTopLeftMode = currentValue
            }

            FormCard.FormDelegateSeparator { above: topLeftActionDrawerModeDelegate; below: topRightActionDrawerModeDelegate }

            FormCard.FormComboBoxDelegate {
                id: topRightActionDrawerModeDelegate
                text: i18n("Top Right Drawer Mode")
                description: i18n("Mode when opening from the top right.")

                model: ListModel {
                    // we can't use i18n with ListElement
                    Component.onCompleted: {
                        append({"name": quickSettings.pinnedString, "value": ShellSettings.Settings.Pinned});
                        append({"name": quickSettings.expandedString, "value": ShellSettings.Settings.Expanded});

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

        FormCard.FormHeader {
            title: i18nc("@title:group", "Lock Screen Shortcuts")
        }

        FormCard.FormCard {
            id: quickActionButtons
            property string noneString: i18nc("@item:inlistbox", "None")
            property string flashlightString: i18nc("@item:inlistbox", "Flashlight")
            property string cameraString: i18nc("@item:inlistbox", "Camera")

            FormCard.FormComboBoxDelegate {
                id: lockscreenLeftButtonDelegate
                text: i18nc("@label:listbox", "Left button")

                model: ListModel {
                    Component.onCompleted: {
                        append({"name": quickActionButtons.noneString, "value": ShellSettings.Settings.None});
                        append({"name": quickActionButtons.flashlightString, "value": ShellSettings.Settings.Flashlight});
                        // append({"name": quickActionButtons.cameraString, "value": ShellSettings.Settings.Camera});
                        lockscreenLeftButtonDelegate.currentIndex = lockscreenLeftButtonDelegate.indexOfValue(ShellSettings.Settings.lockscreenLeftButtonAction)
                    }
                }

                textRole: "name"
                valueRole: "value"

                Component.onCompleted: {
                    dialog.parent = root
                }
                onCurrentValueChanged: ShellSettings.Settings.lockscreenLeftButtonAction = currentValue
            }
            
            FormCard.FormDelegateSeparator { above: lockscreenRightButtonDelegate; below: lockscreenLeftButtonDelegate }

            FormCard.FormComboBoxDelegate {
                id: lockscreenRightButtonDelegate
                text: i18nc("@label:listbox", "Right button")

                model: ListModel {
                    Component.onCompleted: {
                        append({"name": quickActionButtons.noneString, "value": ShellSettings.Settings.None});
                        append({"name": quickActionButtons.flashlightString, "value": ShellSettings.Settings.Flashlight});
                        // append({"name": quickActionButtons.cameraString, "value": ShellSettings.Settings.Camera});
                        lockscreenRightButtonDelegate.currentIndex = lockscreenRightButtonDelegate.indexOfValue(ShellSettings.Settings.lockscreenRightButtonAction)
                    }
                }

                textRole: "name"
                valueRole: "value"

                Component.onCompleted: {
                    dialog.parent = root
                }
                onCurrentValueChanged: ShellSettings.Settings.lockscreenRightButtonAction = currentValue
            }
        }
    }
}
