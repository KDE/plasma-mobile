/*
 *  Copyright 2013 Marco Martin <mart@kde.org>
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

import QtQuick 2.0

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

Row {
    id: root

    property alias reason: messageText.text

    clip: true

    PlasmaCore.IconItem {
        id: icon
        anchors.verticalCenter: parent.verticalCenter
        width: units.iconSizes.huge
        height: width
        source: "dialog-error"
    }

    PlasmaComponents.Label {
        id: messageText
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width - icon.width
        wrapMode: Text.Wrap
    }
}
