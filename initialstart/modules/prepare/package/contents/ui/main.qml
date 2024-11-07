// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import org.kde.kirigami 2.20 as Kirigami
import org.kde.kirigamiaddons.formcard 1.0 as FormCard
import org.kde.plasma.mobileinitialstart.prepare 1.0 as Prepare
import org.kde.plasma.private.mobileshell.screenbrightnessplugin as ScreenBrightness

import org.kde.plasma.mobileinitialstart.initialstart

InitialStartModule {
    id: module
    contentItem: Item {
        id: root
        property string name: i18n("Before we get started…")

        readonly property real cardWidth: Math.min(Kirigami.Units.gridUnit * 30, root.width - Kirigami.Units.gridUnit * 2)

        ScreenBrightness.ScreenBrightnessUtil {
            id: screenBrightness
        }

        ScrollView {
            anchors {
                fill: parent
                topMargin: Kirigami.Units.gridUnit
            }

            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            contentWidth: -1

            ColumnLayout {
                width: root.width
                spacing: Kirigami.Units.gridUnit

                Label {
                    Layout.leftMargin: Kirigami.Units.gridUnit
                    Layout.rightMargin: Kirigami.Units.gridUnit
                    Layout.alignment: Qt.AlignTop
                    Layout.fillWidth: true

                    visible: screenBrightness.brightnessAvailable
                    wrapMode: Text.Wrap
                    horizontalAlignment: Text.AlignHCenter
                    text: i18n("Adjust the screen brightness to be comfortable for the installation process.")
                }

                FormCard.FormCard {
                    id: brightnessCard
                    visible: screenBrightness.brightnessAvailable
                    maximumWidth: root.cardWidth

                    Layout.alignment: Qt.AlignTop | Qt.AlignHCenter

                    FormCard.AbstractFormDelegate {
                        background: null

                        contentItem: RowLayout {
                            spacing: Kirigami.Units.gridUnit

                            Kirigami.Icon {
                                implicitWidth: Kirigami.Units.iconSizes.smallMedium
                                implicitHeight: Kirigami.Units.iconSizes.smallMedium
                                source: "brightness-low"
                            }

                            Slider {
                                id: brightnessSlider
                                Layout.fillWidth: true
                                from: 1
                                to: screenBrightness.maxBrightness
                                value: screenBrightness.brightness
                                onMoved: screenBrightness.brightness = value;

                                // HACK: for some reason, the slider initial value doesn't set without being done after the component completes loading
                                Timer {
                                    interval: 0
                                    running: true
                                    repeat: false
                                    onTriggered: brightnessSlider.value = Qt.binding(() => screenBrightness.brightness)
                                }
                            }

                            Kirigami.Icon {
                                implicitWidth: Kirigami.Units.iconSizes.smallMedium
                                implicitHeight: Kirigami.Units.iconSizes.smallMedium
                                source: "brightness-high"
                            }
                        }
                    }
                }

                Label {
                    Layout.leftMargin: Kirigami.Units.gridUnit
                    Layout.rightMargin: Kirigami.Units.gridUnit
                    Layout.alignment: Qt.AlignTop
                    Layout.fillWidth: true

                    wrapMode: Text.Wrap
                    horizontalAlignment: Text.AlignHCenter
                    text: i18n("Adjust the size of elements on the screen.")
                }

                FormCard.FormCard {
                    id: scalingCard
                    maximumWidth: root.cardWidth

                    Layout.alignment: Qt.AlignTop | Qt.AlignHCenter

                    FormCard.FormComboBoxDelegate {
                        id: displayScaling
                        text: i18n("Display Scaling")
                        displayMode: FormCard.FormComboBoxDelegate.Dialog
                        currentIndex: Prepare.PrepareUtil.scalingOptions.indexOf(Prepare.PrepareUtil.scaling.toString() + "%");
                        model: Prepare.PrepareUtil.scalingOptions

                        // remove % suffix
                        onCurrentValueChanged: Prepare.PrepareUtil.scaling = parseInt(currentValue.substring(0, currentValue.length - 1));
                    }
                }

                FormCard.FormCard {
                    id: darkThemeCard
                    maximumWidth: root.cardWidth

                    Layout.alignment: Qt.AlignTop | Qt.AlignHCenter

                    FormCard.FormSwitchDelegate {
                        id: darkThemeSwitch
                        text: i18n("Dark Theme")
                        checked: Prepare.PrepareUtil.usingDarkTheme
                        onCheckedChanged: {
                            if (checked !== Prepare.PrepareUtil.usingDarkTheme) {
                                Prepare.PrepareUtil.usingDarkTheme = checked;
                            }
                        }
                    }
                }
            }
        }
    }
}