/*
 *   Copyright 2014 Antonis Tsiapaliokas <antonis.tsiapaliokas@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2 or
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

import QtQuick 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kquickcontrolsaddons 2.0 as KQuickControlsAddons
import org.kde.plasma.extras 2.0 as PlasmaExtras

Item {
    id: main

    z: 999
    x: plasmoid.availableScreenRect.x
    y: plasmoid.availableScreenRect.y
    width: plasmoid.availableScreenRect.width
    height: plasmoid.availableScreenRect.height

    property int iconSize: units.iconSizes.small
    property int iconWidth: units.iconSizes.smallMedium
    property int iconHeight: iconWidth

    ToolBoxButton {
        id: toolBoxButton
        visible: false
        Component.onCompleted: {
            toolBoxButton.x = main.width / 14;
            toolBoxButton.y = main.height / 14;
            toolBoxButton.visible = true
        }
    }
}
