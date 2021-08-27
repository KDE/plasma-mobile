/*
 *   SPDX-FileCopyrightText: 2012-2013 Daniel Nicoletti <dantti12@gmail.com>
 *   SPDX-FileCopyrightText: 2013, 2015 Kai Uwe Broulik <kde@privat.broulik.de>
 *   SPDX-FileCopyrightText: 2021 Devin Lin <espidev@gmail.com>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.0
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.1
import org.kde.kirigami 2.12 as Kirigami

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PC3

Item {
    id: brightnessRoot
    
    implicitHeight: brightnessRow.implicitHeight
    
    property int screenBrightness
    property bool disableBrightnessUpdate: true
    readonly property int maximumScreenBrightness: pmSource.data["PowerDevil"] ? pmSource.data["PowerDevil"]["Maximum Screen Brightness"] || 0 : 0
    
    onScreenBrightnessChanged: {
        brightnessSlider.value = brightnessRoot.screenBrightness
        if (!disableBrightnessUpdate) {
            var service = pmSource.serviceForSource("PowerDevil");
            var operation = service.operationDescription("setBrightness");
            operation.brightness = screenBrightness;
            operation.silent = true
            service.startOperationCall(operation);
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
        onDataChanged: {
            disableBrightnessUpdate = true;
            brightnessRoot.screenBrightness = pmSource.data["PowerDevil"]["Screen Brightness"];
            disableBrightnessUpdate = false;
        }
    }
    
    Component.onCompleted: {
        brightnessSlider.moved.connect(function() {
            brightnessRoot.screenBrightness = brightnessSlider.value;
        });
        disableBrightnessUpdate = false;
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
            Layout.preferredWidth: Math.round(PlasmaCore.Units.gridUnit * 1.75)
            Layout.preferredHeight: width
            source: "low-brightness"
        }

        Slider {
            id: brightnessSlider
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            value: screenBrightness
            from: 1
            to: maximumScreenBrightness
        }
        
        PlasmaCore.IconItem {
            Layout.alignment: Qt.AlignVCenter
            Layout.rightMargin: PlasmaCore.Units.smallSpacing
            Layout.preferredWidth: Math.round(PlasmaCore.Units.gridUnit * 1.75)
            Layout.preferredHeight: width
            source: "high-brightness"
        }
    }
}
