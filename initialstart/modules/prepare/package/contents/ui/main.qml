// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import org.kde.kirigami 2.20 as Kirigami
import org.kde.kirigamiaddons.formcard 1.0 as FormCard
import org.kde.plasma.mobileinitialstart.prepare as Prepare
import org.kde.plasma.plasma5support 2.0 as P5Support

Item {
    id: root
    property string name: i18n("Before we get started…")

    readonly property real cardWidth: Math.min(Kirigami.Units.gridUnit * 30, root.width - Kirigami.Units.gridUnit * 2)

    // brightness controls
    property int screenBrightness: 0
    property bool disableBrightnessUpdate: true
    readonly property int maximumScreenBrightness: pmSource.data["PowerDevil"] ? pmSource.data["PowerDevil"]["Maximum Screen Brightness"] || 0 : 0
    property QtObject updateScreenBrightnessJob

    function updateBrightnessUI() {
        if (updateScreenBrightnessJob)
            return;

        root.disableBrightnessUpdate = true;
        root.screenBrightness = pmSource.data["PowerDevil"]["Screen Brightness"];
        root.disableBrightnessUpdate = false;
    }

    onScreenBrightnessChanged: {
        brightnessSlider.value = root.screenBrightness

        if (!disableBrightnessUpdate) {
            const service = pmSource.serviceForSource("PowerDevil");
            const operation = service.operationDescription("setBrightness");
            operation.brightness = screenBrightness;
            operation.silent = true; // don't show OSD

            updateScreenBrightnessJob = service.startOperationCall(operation);
            updateScreenBrightnessJob.finished.connect(function (job) {
                root.updateBrightnessUI();
            });
        }
    }

    P5Support.DataSource {
        id: pmSource
        engine: "powermanagement"
        connectedSources: ["PowerDevil"]
        onSourceAdded: if (source === "PowerDevil") {
            disconnectSource(source);
            connectSource(source);
        }
        onDataChanged: root.updateBrightnessUI()
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

                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
                text: i18n("Adjust the screen brightness to be comfortable for the installation process.")
            }

            FormCard.FormCard {
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
                            to: root.maximumScreenBrightness
                            value: root.screenBrightness
                            onMoved: root.screenBrightness = value;
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
        }
    }
}
