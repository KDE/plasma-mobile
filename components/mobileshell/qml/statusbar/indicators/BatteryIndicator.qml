/*
 *  SPDX-FileCopyrightText: 2021 Devin Lin <espidev@gmail.com>
 *  SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.6
import QtQuick.Layouts 1.4

import org.kde.kirigami 2.20 as Kirigami

import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.workspace.components 2.0 as PW
import org.kde.plasma.private.mobileshell as MobileShell

RowLayout {
    property real textPixelSize: Kirigami.Units.gridUnit * 0.6

    visible: MobileShell.BatteryInfo.isVisible

    PW.BatteryIcon {
        id: battery
        Layout.preferredWidth: height
        Layout.fillHeight: true
        hasBattery: true
        percent: MobileShell.BatteryInfo.percent
        pluggedIn: MobileShell.BatteryInfo.pluggedIn

        height: batteryLabel.height
        width: batteryLabel.height
    }

    PlasmaComponents.Label {
        id: batteryLabel
        text: i18n("%1%", MobileShell.BatteryInfo.percent)
        Layout.alignment: Qt.AlignVCenter

        color: Kirigami.Theme.textColor
        font.pixelSize: textPixelSize
    }
}
