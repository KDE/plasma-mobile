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

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents


RowLayout {

    property alias icon: icon.source
    property alias text: label.text
    PlasmaCore.IconItem {
        id: icon
        colorGroup: PlasmaCore.ColorScope.colorGroup

        Layout.fillHeight: true
        Layout.preferredWidth: height
    }
    PlasmaComponents.Label {
        id: label
        visible: text.length > 0
        color: PlasmaCore.ColorScope.textColor
        font.pixelSize: parent.height / 2
    }
}
