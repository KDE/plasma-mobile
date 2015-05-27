/*
 *   Copyright 2015 Marco Martin <notmart@gmail.com>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Library General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 2.1
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.plasmoid 2.0

RowLayout {
    id: root
    spacing: units.smallSpacing
    property int screenBrightness
    readonly property int maximumScreenBrightness: pmSource.data["PowerDevil"] ? pmSource.data["PowerDevil"]["Maximum Screen Brightness"] || 0 : 0
    Plasmoid.preferredRepresentation: Plasmoid.fullRepresentation

    PlasmaCore.DataSource {
        id: pmSource
        engine: "powermanagement"
        connectedSources: ["PowerDevil"]

        onDataChanged: {
            root.screenBrightness = source.data["PowerDevil"]["Screen Brightness"];
        }
    }

    PlasmaCore.IconItem {
        colorGroup: PlasmaCore.ColorScope.colorGroup
        Layout.minimumHeight: units.iconSizes.medium
        Layout.minimumWidth: Layout.minimumHeight
        source: plasmoid.icon
    }
    PlasmaComponents.Slider {
        id: slider
        Layout.fillWidth: true
        value: screenBrightness
        minimumValue: maximumValue > 100 ? 1 : 0
        maximumValue: root.maximumScreenBrightness
    }
}
