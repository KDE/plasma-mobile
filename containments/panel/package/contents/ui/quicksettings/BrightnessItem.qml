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

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PC3

RowLayout {
    id: brightnessRoot
    property alias value: brightnessSlider.value
    property alias maximumValue: brightnessSlider.to

    signal moved

    spacing: units.smallSpacing

    PlasmaCore.IconItem {
        Layout.alignment: Qt.AlignVCenter
        Layout.leftMargin: Kirigami.Units.largeSpacing
        Layout.preferredWidth: units.iconSizes.medium
        Layout.preferredHeight: width
        source: "low-brightness"
    }

    Slider {
        id: brightnessSlider
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignVCenter
        onMoved: brightnessRoot.moved()
        from: 1
    }
    
    PlasmaCore.IconItem {
        Layout.alignment: Qt.AlignVCenter
        Layout.rightMargin: Kirigami.Units.largeSpacing
        Layout.preferredWidth: units.iconSizes.medium
        Layout.preferredHeight: width
        source: "high-brightness"
    }
}
