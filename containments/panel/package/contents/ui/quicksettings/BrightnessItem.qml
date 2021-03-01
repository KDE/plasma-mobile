/*
 *   SPDX-FileCopyrightText: 2012-2013 Daniel Nicoletti <dantti12@gmail.com>
 *   SPDX-FileCopyrightText: 2013, 2015 Kai Uwe Broulik <kde@privat.broulik.de>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.0
import QtQuick.Layouts 1.1

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PC3

RowLayout {
    id: brightnessRoot
    property alias icon: brightnessIcon.source
    property alias label: brightnessLabel.text
    property alias value: brightnessSlider.value
    property alias maximumValue: brightnessSlider.to

    signal moved

    spacing: units.gridUnit

    PlasmaCore.IconItem {
        id: brightnessIcon
        Layout.alignment: Qt.AlignTop
        Layout.preferredWidth: units.iconSizes.medium
        Layout.preferredHeight: width
    }

    Column {
        id: brightnessColumn
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignTop
        spacing: 0

        PC3.Label {
            id: brightnessLabel
            width: parent.width
            height: paintedHeight
        }

        PC3.Slider {
            id: brightnessSlider
            width: parent.width
            onMoved: brightnessRoot.moved()
            from: 1
            //stepSize: 1
        }
    }
}
