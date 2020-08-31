/*
 *  Copyright 2019 Marco Martin <mart@kde.org>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  2.010-1301, USA.
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
