/*
 *   SPDX-FileCopyrightText: 2012-2013 Daniel Nicoletti <dantti12@gmail.com>
 *   SPDX-FileCopyrightText: 2013, 2015 Kai Uwe Broulik <kde@privat.broulik.de>
 *   SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Layouts 1.1
import org.kde.kirigami 2.12 as Kirigami

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PC3

Item {
    id: root
    
    implicitHeight: brightnessRow.implicitHeight
    
    property int screenBrightness
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
        if (!brightnessSlider.pressed && !brightnessTimer.running) {
            brightnessSlider.value = root.screenBrightness;
        }
        
        if (!disableBrightnessUpdate) {
            var service = pmSource.serviceForSource("PowerDevil");
            var operation = service.operationDescription("setBrightness");
            operation.brightness = screenBrightness;
            operation.silent = true; // don't show OSD
            
            updateScreenBrightnessJob = service.startOperationCall(operation);
            updateScreenBrightnessJob.finished.connect(function (job) {
                root.updateBrightnessUI();
            });
        }
    }
    
    PlasmaCore.DataSource {
        id: pmSource
        engine: "powermanagement"
        connectedSources: ["PowerDevil"]
        onSourceAdded: {
            if (source === "PowerDevil") {
                disconnectSource(source);
                connectSource(source);
            }
        }
        onDataChanged: root.updateBrightnessUI()
    }

    // we want to smoothen the slider so it doesn't jump immediately after you let go
    Timer {
        id: brightnessTimer
        interval: 500
        onTriggered: {
            brightnessSlider.value = root.screenBrightness;
        }
    }

    // send brightness events a maximum of 5 times a second
    Timer {
        id: sendEventTimer
        interval: 200
        onTriggered: root.screenBrightness = brightnessSlider.value
    }
    
    RowLayout {
        id: brightnessRow
        spacing: PlasmaCore.Units.smallSpacing * 2
        
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top

        PlasmaCore.IconItem {
            Layout.alignment: Qt.AlignVCenter
            Layout.leftMargin: PlasmaCore.Units.smallSpacing
            Layout.preferredWidth: PlasmaCore.Units.iconSizes.smallMedium
            Layout.preferredHeight: width
            source: "low-brightness"
        }

        PC3.Slider {
            id: brightnessSlider
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            from: 1
            to: root.maximumScreenBrightness
            value: root.screenBrightness
            
            onMoved: {
                if (!sendEventTimer.running) {
                    root.screenBrightness = value;
                    sendEventTimer.restart();
                }
            }

            onPressedChanged: {
                if (!pressed) {
                    brightnessTimer.restart();
                } else {
                    brightnessTimer.stop();
                }
            }
        }
        
        PlasmaCore.IconItem {
            Layout.alignment: Qt.AlignVCenter
            Layout.rightMargin: PlasmaCore.Units.smallSpacing
            Layout.preferredWidth: PlasmaCore.Units.iconSizes.smallMedium
            Layout.preferredHeight: width
            source: "high-brightness"
        }
    }
}
