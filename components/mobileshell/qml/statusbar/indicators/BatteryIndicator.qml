/*
 *  SPDX-FileCopyrightText: 2024 Sebastian Kügler <sebas@kde.org>
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
import org.kde.plasma.private.battery // needed for charging state

RowLayout {
    property real textPixelSize: Kirigami.Units.gridUnit * 0.6

    visible: MobileShell.BatteryInfo.isVisible

    ListView {
        id: batteryRepeater

        property int batteryWidth: 0

        spacing: root.elementSpacing
        model: MobileShell.BatteryInfo.batteries
        orientation: ListView.Horizontal

        Layout.alignment: Qt.AlignVCenter
        Layout.preferredWidth: (batteryRepeater.batteryWidth + root.elementSpacing) * batteryRepeater.count
        Layout.fillHeight: true
        Layout.fillWidth: false

        delegate: RowLayout {

            Layout.preferredWidth: batteryRepeater.batteryWidth
            Layout.fillHeight: false
            Layout.alignment: Qt.AlignVCenter

            height: batteryRepeater.height
            width: childrenRect.width

            PW.BatteryIcon {
                id: battery

                Layout.alignment: Qt.AlignVCenter
                height: batteryLabel.height
                width: batteryLabel.height

                hasBattery: PluggedIn
                percent: Percent
                pluggedIn: ChargeState === BatteryControlModel.Charging
            }

            PlasmaComponents.Label {
                id: batteryLabel
                text: i18n("%1%", Percent)
                Layout.alignment: Qt.AlignVCenter

                color: Kirigami.Theme.textColor
                font.pixelSize: textPixelSize
            }

            Component.onCompleted: {
                // ListView & RowLayout have problems with childrenRect size,
                // set it here so it propagates up nicely
                batteryRepeater.batteryWidth = batteryLabel.width + battery.width
            }
        }
    }
}
