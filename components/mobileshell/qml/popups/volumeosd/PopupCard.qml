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
import org.kde.plasma.private.mobileshell as MobileShell

// capture presses on the audio applet so it doesn't close the overlay
Controls.Control {
    id: content
    implicitWidth: Math.min(Kirigami.Units.gridUnit * 20, Screen.width - Kirigami.Units.gridUnit * 2)
    padding: Kirigami.Units.smallSpacing * 2

    property bool popupBackground: false

    Kirigami.Theme.colorSet: Kirigami.Theme.View
    Kirigami.Theme.inherit: false

    MobileShell.PanelBackground {
        anchors.fill: parent
        panelType: content.popupBackground ?
            MobileShell.PanelBackground.PanelType.Popup :
            MobileShell.PanelBackground.PanelType.Drawer
    }
}
