/*
 *  SPDX-FileCopyrightText: 2021 Devin Lin <espidev@gmail.com>
 *  SPDX-FileCopyrightText: 2024 Micah Stanley <stanleymicah@proton.me>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import QtQuick.Window

import QtQuick.Effects
import Qt5Compat.GraphicalEffects

import org.kde.kirigami 2.20 as Kirigami
import org.kde.ksvg 1.0 as KSvg
import org.kde.plasma.components 3.0 as PlasmaComponents

// capture presses on the audio applet so it doesn't close the overlay
Controls.Control {
    id: content
    implicitWidth: Math.min(Kirigami.Units.gridUnit * 20, Screen.width - Kirigami.Units.gridUnit * 2)
    padding: Kirigami.Units.smallSpacing * 2

    Kirigami.Theme.colorSet: Kirigami.Theme.View
    Kirigami.Theme.inherit: false

    MultiEffect {
        anchors.fill: parent
        source: simpleShadow
        blurMax: 16
        shadowEnabled: true
        shadowVerticalOffset: 1
        shadowOpacity: 0.85
        shadowColor: Qt.lighter(Kirigami.Theme.backgroundColor, 0.2)
    }

    Rectangle {
        id: simpleShadow
        anchors.fill: parent
        anchors.leftMargin: -1
        anchors.rightMargin: -1
        anchors.bottomMargin: -1

        color: {
            let darkerBackgroundColor = Qt.darker(Kirigami.Theme.backgroundColor, 1.3);
            return Qt.rgba(darkerBackgroundColor.r, darkerBackgroundColor.g, darkerBackgroundColor.b, 0.5)
        }
        radius: Kirigami.Units.cornerRadius
    }

    Rectangle {
        anchors.fill: parent
        color: Qt.lighter(Kirigami.Theme.backgroundColor, 1.5)
        opacity: 0.85
        radius: Kirigami.Units.cornerRadius
    }
}
