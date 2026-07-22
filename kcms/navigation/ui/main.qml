/*
 * SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
 * SPDX-FileCopyrightText: 2025 Luis Büchi <luis.buechi@kdemail.net>
 * SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import QtQuick.Effects

import Qt5Compat.GraphicalEffects

import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import org.kde.kirigamiaddons.formcard 1.0 as FormCard
import org.kde.plasma.private.mobileshell.shellsettingsplugin as ShellSettings

KCM.SimpleKCM {
    id: root

    title: i18n("Navigation")

    topPadding: 0
    bottomPadding: 0
    leftPadding: 0
    rightPadding: 0

    ColumnLayout {
        ListView {
            id: tutorialView

            property int phoneWidth: Math.min(Screen.width * 0.25, gestureSelectionCard.maximumWidth * 0.65)
            property int phoneHeight: phoneWidth * Screen.height / Screen.width
            property int count: 3
            property int fingerSize: 20

            Layout.alignment: Qt.AlignCenter
            Layout.fillWidth: true
            Layout.preferredHeight: phoneHeight + fingerSize / 2
            Layout.topMargin: Kirigami.Units.largeSpacing * 2
            Layout.leftMargin: Kirigami.Units.largeSpacing * 2
            Layout.rightMargin: Kirigami.Units.largeSpacing * 2

            clip: true
            orientation: ListView.Horizontal
            spacing: Math.min(Math.round((tutorialView.width - phoneWidth) * 0.5), Kirigami.Units.largeSpacing * 6)

            snapMode: ListView.SnapOneItem
            highlightRangeMode: ListView.StrictlyEnforceRange
            preferredHighlightBegin: width / 2 - phoneWidth / 2
            preferredHighlightEnd: width / 2 + phoneWidth / 2

            property int activeTutorialIndex: currentIndex

            model: tutorialView.count
            delegate: Item {
                id: delegateItem

                required property int index

                width: tutorialView.phoneWidth
                height: tutorialView.phoneHeight

                property bool isCurrentItem: ListView.isCurrentItem
                property bool isGestureMode: !ShellSettings.Settings.navigationPanelEnabled

                onIsCurrentItemChanged: {
                    if (isCurrentItem) {
                        tutorialPhone.playTutorial(isGestureMode, delegateItem.index);
                    } else {
                        tutorialPhone.stopAllAnimations(isGestureMode);
                    }
                }

                onIsGestureModeChanged: {
                    if (isCurrentItem) {
                        tutorialPhone.playTutorial(isGestureMode, delegateItem.index);
                    } else {
                        tutorialPhone.stopAllAnimations(isGestureMode);
                    }
                }

                function playTutorial(gestureMode, idx) {
                    tutorialPhone.playTutorial(gestureMode, idx);
                }

                TutorialPhone {
                    id: tutorialPhone
                    anchors.fill: parent
                    phoneWidth: delegateItem.width
                    phoneHeight: delegateItem.height
                    fingerSize: tutorialView.fingerSize

                    Component.onCompleted: {
                        if (delegateItem.index === tutorialView.activeTutorialIndex) {
                            tutorialPhone.playTutorial(isGestureMode, delegateItem.index);
                        } else {
                            tutorialPhone.stopAllAnimations(isGestureMode);
                        }
                    }
                }
            }

            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: Rectangle {
                    id: maskRect
                    width: tutorialView.width
                    height: tutorialView.height

                    property real gradientBoundaries: Math.max((tutorialView.width * 0.5) - (tutorialView.phoneWidth * 0.5) - (Kirigami.Units.gridUnit * 6), 0) / Math.max(1, width)
                    property real gradientDistance: Math.max(((tutorialView.width * 0.5) - (tutorialView.phoneWidth * 0.5)) / Math.max(1, width), maskRect.gradientBoundaries)

                    gradient: Gradient {
                        orientation: Gradient.Horizontal

                        GradientStop { position: maskRect.gradientBoundaries; color: 'transparent' }
                        GradientStop { position: 0 + maskRect.gradientDistance; color: 'white' }
                        GradientStop { position: 1.0 - maskRect.gradientDistance; color: 'white' }
                        GradientStop { position: 1.0 - maskRect.gradientBoundaries; color: 'transparent' }
                    }
                }
            }
        }

        Controls.PageIndicator {
            currentIndex: tutorialView.activeTutorialIndex
            count: tutorialView.count

            Layout.alignment: Qt.AlignCenter
        }

        FormCard.FormSectionText {
            id: tutorialText
            verticalAlignment: Text.AlignTop
            Layout.preferredHeight: textMetrics.lineSpacing * 2

            property bool isGestureMode: !ShellSettings.Settings.navigationPanelEnabled

            FontMetrics {
                id: textMetrics
                font: tutorialText.font
            }

            text: {
                if (isGestureMode) {
                    switch (tutorialView.activeTutorialIndex) {
                        case 0: return i18n("Swipe up, hold, then release to enter the Task Switcher.");
                        case 1: return i18n("Swipe up from the bottom to return to Home Screen.");
                        case 2: return i18n("Swipe horizontally near the bottom to scrub through open tasks. Release to select.");
                        default: return "";
                    }
                } else {
                    switch (tutorialView.activeTutorialIndex) {
                        case 0: return i18n("Tap the square button to enter the Task Switcher. Double tap to switch to the last used application.");
                        case 1: return i18n("Tap the center button to return to the Home Screen.");
                        case 2: return i18n("Tap the X button to close the current application.");
                        default: return "";
                    }
                }
            }
        }

        FormCard.FormHeader {
            title: i18nc("@label", "Navigation Mode")
        }
        FormCard.FormCard {
            id: gestureSelectionCard

            Controls.ButtonGroup {
                id: positionGroup
                buttons: [navPanelRadio, gesturesRadio]
            }

            FormCard.FormRadioDelegate {
                id: navPanelRadio
                text: i18nc("Nav Panel Navigation Mode", "Buttons")
                checked: ShellSettings.Settings.navigationPanelEnabled
                onClicked: ShellSettings.Settings.navigationPanelEnabled = true;
            }

            FormCard.FormRadioDelegate {
                id: gesturesRadio
                text: i18nc("Gestures Navigation Mode", "Swipe Gestures")
                checked: !ShellSettings.Settings.navigationPanelEnabled
                onClicked: ShellSettings.Settings.navigationPanelEnabled = false;
            }

            FormCard.FormDelegateSeparator { visible: keyboardToggleDelegate.visible; above: gesturesRadio; below: keyboardToggleDelegate }

            FormCard.FormSwitchDelegate {
                id: keyboardToggleDelegate
                visible: ShellSettings.Settings.navigationPanelEnabled
                text: i18n("Always show keyboard toggle")
                description: i18n("Whether to always show the keyboard toggle button on the navigation panel.")
                checked: ShellSettings.Settings.alwaysShowKeyboardToggleOnNavigationPanel
                onCheckedChanged: {
                    if (checked != ShellSettings.Settings.alwaysShowKeyboardToggleOnNavigationPanel) {
                        ShellSettings.Settings.alwaysShowKeyboardToggleOnNavigationPanel = checked;
                    }
                }
            }

            FormCard.FormDelegateSeparator { visible: gesturePanelToggleDelegate.visible }

            FormCard.FormSwitchDelegate {
                id: gesturePanelToggleDelegate
                visible: !ShellSettings.Settings.navigationPanelEnabled
                text: i18n("Show gesture handle")
                description: i18n("Whether to add a panel on the bottom with a gesture handle.")
                checked: ShellSettings.Settings.gesturePanelEnabled
                onCheckedChanged: {
                    if (checked != ShellSettings.Settings.gesturePanelEnabled) {
                        ShellSettings.Settings.gesturePanelEnabled = checked;
                    }
                }
            }
        }
    }
}
