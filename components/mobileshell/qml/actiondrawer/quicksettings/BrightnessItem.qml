/*
 *   SPDX-FileCopyrightText: 2012-2013 Daniel Nicoletti <dantti12@gmail.com>
 *   SPDX-FileCopyrightText: 2013, 2015 Kai Uwe Broulik <kde@privat.broulik.de>
 *   SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Layouts 1.1
import org.kde.kirigami 2.20 as Kirigami

import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components 3.0 as PC3

Item {
    id: root

    implicitHeight: brightnessRow.implicitHeight

    property alias value: brightnessSlider.value
    property alias maximumValue: brightnessSlider.to

    signal moved()

    RowLayout {
        id: brightnessRow
        spacing: Kirigami.Units.smallSpacing * 2

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top

        Kirigami.Icon {
            Layout.alignment: Qt.AlignVCenter
            Layout.leftMargin: Kirigami.Units.smallSpacing
            Layout.preferredWidth: Kirigami.Units.iconSizes.smallMedium
            Layout.preferredHeight: width
            source: "low-brightness"
        }

        PC3.Slider {
            id: brightnessSlider
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            from: 1

            onMoved: root.moved()
        }

        Kirigami.Icon {
            Layout.alignment: Qt.AlignVCenter
            Layout.rightMargin: Kirigami.Units.smallSpacing
            Layout.preferredWidth: Kirigami.Units.iconSizes.smallMedium
            Layout.preferredHeight: width
            source: "high-brightness"
        }
    }
}
