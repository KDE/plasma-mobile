/*
 *  SPDX-FileCopyrightText: 2021 Devin Lin <espidev@gmail.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import QtQuick.Window

import org.kde.kirigami 2.20 as Kirigami
import org.kde.ksvg 1.0 as KSvg
import org.kde.plasma.components 3.0 as PlasmaComponents

// capture presses on the audio applet so it doesn't close the overlay
Controls.Control {
    id: content
    implicitWidth: Math.min(Kirigami.Units.gridUnit * 20, parent.width - Kirigami.Units.gridUnit * 2)
    padding: Kirigami.Units.smallSpacing * 2
    background: KSvg.FrameSvgItem {
        imagePath: "widgets/background"
        anchors.margins: -Kirigami.Units.smallSpacing * 2
        anchors.fill: parent
    }
}
