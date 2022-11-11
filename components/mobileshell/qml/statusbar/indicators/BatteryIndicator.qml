/*
 *  SPDX-FileCopyrightText: 2021 Devin Lin <espidev@gmail.com>
 *  SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.6
import QtQuick.Layouts 1.4

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.workspace.components 2.0 as PW
import org.kde.plasma.private.mobileshell 1.0 as MobileShell

RowLayout {
    readonly property var provider: MobileShell.BatteryInfo {}
    property real textPixelSize: PlasmaCore.Units.gridUnit * 0.6
    
    visible: provider.isVisible

    PW.BatteryIcon {
        id: battery
        Layout.preferredWidth: height
        Layout.fillHeight: true
        hasBattery: true
        percent: provider.percent
        pluggedIn: provider.pluggedIn

        height: batteryLabel.height
        width: batteryLabel.height
    }

    PlasmaComponents.Label {
        id: batteryLabel
        text: i18n("%1%", provider.percent)
        Layout.alignment: Qt.AlignVCenter

        color: PlasmaCore.ColorScope.textColor
        font.pixelSize: textPixelSize
    }
}
