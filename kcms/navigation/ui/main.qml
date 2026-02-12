/*
 * SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
 * SPDX-FileCopyrightText: 2025 Luis Büchi <luis.buechi@kdemail.net>
 * SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15 as Controls

import org.kde.kirigami 2.19 as Kirigami
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
                text: i18nc("Nav Panel Navigation Mode", "Panel")
                checked: ShellSettings.Settings.navigationPanelEnabled
                onClicked: ShellSettings.Settings.navigationPanelEnabled = true;
            }

            FormCard.FormRadioDelegate {
                id: gesturesRadio
                text: i18nc("Gestures Navigation Mode", "Gestures")
                checked: !ShellSettings.Settings.navigationPanelEnabled
                onClicked: ShellSettings.Settings.navigationPanelEnabled = false;
            }

            FormCard.FormDelegateSeparator {
                visible: !ShellSettings.Settings.navigationPanelEnabled
                above: gesturesRadio
                below: tutorialContainer
            }

            Item {
                id: tutorialContainer
                visible: !ShellSettings.Settings.navigationPanelEnabled

                property int phoneWidth: Math.min(Window.width * 0.4, gestureSelectionCard.maximumWidth * 0.9)
                property int phoneHeight: phoneWidth * Window.height / Window.width
                property int count: 3
                property int fingerSize: 20

                Layout.alignment: Qt.AlignCenter
                Layout.preferredWidth: phoneWidth
                Layout.preferredHeight: phoneHeight + fingerSize / 2
                Layout.topMargin: Kirigami.Units.largeSpacing * 2

                clip: true

                MouseArea {
                    id: tutorialSwitcherInput

                    anchors.fill: tutorialContainer

                    preventStealing: true

                    property int activeTutorialIndex: 0

                    property real lastX
                    property real lastDelta

                    onPressedChanged: {
                        if (pressed) {
                            lastX = mouseX;
                        }
                        else {
                            let moveOffset = lastDelta > 0 ? -0.45 : 0.45
                            let candidateIndex = Math.round(-tutorialLayout.offset / (tutorialLayout.spacing + tutorialContainer.phoneWidth) + moveOffset);
                            activeTutorialIndex = Math.max(0, Math.min(tutorialContainer.count - 1, candidateIndex));
                            updateActiveTutorial();
                            releaseAnim.start()
                        }
                    }

                    function updateActiveTutorial(): void {
                        switch (activeTutorialIndex) {
                            case 0:
                                switchTutorial.loopSwitcherAnimation();
                                flickTutorial.stopAnimation();
                                scrubTutorial.stopAnimation();
                                break;
                            case 1:
                                switchTutorial.stopAnimation();
                                flickTutorial.loopFlickAnimation();
                                scrubTutorial.stopAnimation();
                                break;
                            case 2:
                                switchTutorial.stopAnimation();
                                flickTutorial.stopAnimation();
                                scrubTutorial.loopScrubAnimation();
                                break;
                        }
                    }

                    onPositionChanged: (mouse) => {
                        let delta = mouse.x - lastX;
                        let endOffset = -(tutorialContainer.count - 1) * (tutorialContainer.phoneWidth + tutorialLayout.spacing);
                        if (activeTutorialIndex == 0 && tutorialLayout.offset > 0 && delta > 0) {
                            // handle overshoot on the left
                            delta /= tutorialLayout.x;
                        }
                        else if (activeTutorialIndex == tutorialContainer.count - 1 && tutorialLayout.offset < endOffset) {
                            // handle overhoot on the right
                            delta /= Math.abs(tutorialLayout.x - endOffset);
                        }
                        tutorialLayout.offset += delta
                        lastDelta = delta;
                        lastX = mouse.x
                    }

                    NumberAnimation {
                        id: releaseAnim

                        target: tutorialLayout
                        property: "offset"

                        to: -tutorialSwitcherInput.activeTutorialIndex * (tutorialContainer.phoneWidth + tutorialLayout.spacing)

                        duration: Kirigami.Units.longDuration
                        easing.type: Easing.InOutQuad
                    }
                }

                Item {
                    Layout.alignment: Qt.AlignCenter
                    Layout.preferredWidth: tutorialContainer.phoneWidth
                    Layout.preferredHeight: tutorialContainer.phoneHeight + tutorialContainer.fingerSize / 2

                    RowLayout {
                        id: tutorialLayout

                        property int offset: 0
                        x: offset

                        width: tutorialContainer.phoneWidth * tutorialContainer.count + Kirigami.Units.largeSpacing * (tutorialContainer.count - 1)
                        height: tutorialContainer.phoneHeight
                        spacing: Kirigami.Units.largeSpacing

                        TutorialPhone {
                            id: switchTutorial

                            phoneWidth: tutorialContainer.phoneWidth
                            phoneHeight: tutorialContainer.phoneHeight
                            fingerSize: tutorialContainer.fingerSize
                            showBackground: false

                            Layout.alignment: Qt.AlignCenter

                            Component.onCompleted: {
                                loopSwitcherAnimation();
                            }
                        }

                        TutorialPhone {
                            id: flickTutorial

                            phoneWidth: tutorialContainer.phoneWidth
                            phoneHeight: tutorialContainer.phoneHeight
                            fingerSize: tutorialContainer.fingerSize

                            Layout.alignment: Qt.AlignCenter
                        }

                        TutorialPhone {
                            id: scrubTutorial

                            phoneWidth: tutorialContainer.phoneWidth
                            phoneHeight: tutorialContainer.phoneHeight
                            fingerSize: tutorialContainer.fingerSize
                            showBackground: false

                            Layout.alignment: Qt.AlignCenter
                        }
                    }
                }
            }

            Controls.PageIndicator {
                visible: !ShellSettings.Settings.navigationPanelEnabled
                currentIndex: tutorialSwitcherInput.activeTutorialIndex
                count: tutorialContainer.count

                Layout.alignment: Qt.AlignCenter
            }

            FormCard.FormSectionText {
                visible: !ShellSettings.Settings.navigationPanelEnabled && tutorialSwitcherInput.activeTutorialIndex == 0

                text: i18n("Swipe up, hold then release to enter Task Switcher")
            }

            FormCard.FormSectionText {
                visible: !ShellSettings.Settings.navigationPanelEnabled && tutorialSwitcherInput.activeTutorialIndex == 1

                text: i18n("Swipe up and release to go to Home Screen")
            }

            FormCard.FormSectionText {
                visible: !ShellSettings.Settings.navigationPanelEnabled && tutorialSwitcherInput.activeTutorialIndex == 2

                text: i18n("Swipe left and right near the bottom screen edge to scrub through open tasks. Release to select a task to focus")
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
