/*
 *  SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.6
import QtQuick.Layouts 1.4

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.workspace.components 2.0 as PW


RowLayout {
    visible: pmSource.data["Battery"]["Has Cumulative"]

    PW.BatteryIcon {
        id: battery
        Layout.preferredWidth: height
        Layout.fillHeight: true
        hasBattery: true
        percent: pmSource.data["Battery"]["Percent"]
        pluggedIn: pmSource.data["AC Adapter"] ? pmSource.data["AC Adapter"]["Plugged in"] : false

        height: batteryLabel.height
        width: batteryLabel.height

        PlasmaCore.DataSource {
            id: pmSource
            engine: "powermanagement"
            connectedSources: ["Battery", "AC Adapter"]
        }
    }

    PlasmaComponents.Label {
        id: batteryLabel
        text: i18n("%1%", battery.percent)
        Layout.alignment: Qt.AlignVCenter

        color: PlasmaCore.ColorScope.textColor
        font.pixelSize: parent.height / 2
    }
}
