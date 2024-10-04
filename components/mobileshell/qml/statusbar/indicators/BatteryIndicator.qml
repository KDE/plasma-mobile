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


    ListView {
        id: batteryRepeater
        spacing: root.elementSpacing

        model: MobileShell.BatteryInfo.batteries

        orientation: ListView.Horizontal
        Layout.alignment: Qt.AlignVCenter
        Layout.preferredWidth: childrenRect.width

        Layout.fillHeight: true

        delegate: RowLayout {

            /* Battery properties (from batterycontrol.h):
             *     enum BatteryRoles {
                *  Percent = Qt::UserRole + 1,
                *  Capacity,
                *  Energy,
                *  PluggedIn,
                *  IsPowerSupply,
                *  ChargeState,
                *  PrettyName,
                *  Type }
                */

            Layout.preferredWidth: childrenRect.width
            Layout.fillHeight: true

            height: batteryLabel.height
            width: childrenRect.width + (root.elementSpacing * index)

            PW.BatteryIcon {
                id: battery

                Layout.fillHeight: true
                height: batteryLabel.height
                width: batteryLabel.height

                hasBattery: true
                percent: Percent
                pluggedIn: PluggedIn

            }

            PlasmaComponents.Label {
                id: batteryLabel
                text: i18n("%1%", Percent)
                Layout.alignment: Qt.AlignVCenter

                color: Kirigami.Theme.textColor
                font.pixelSize: textPixelSize
            }

            Component.onCompleted: {
                console.log("======> Created Battery " + index);
                console.log("        PrettyName: " + PrettyName);
                console.log("        Percent:    " + Percent);
                console.log("        Type:       " + Type);
                console.log("        Energy:     " + Energy);
                console.log("        PluggedIn:  " + PluggedIn);
                console.log("        ChargeState:  " + ChargeState);
            }
        }
    }
}
