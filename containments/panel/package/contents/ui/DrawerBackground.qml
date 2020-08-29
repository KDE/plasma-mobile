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
import QtQuick.Controls 2.4 as QQC2
import QtGraphicalEffects 1.0

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore


QQC2.Control {
    id: root
    leftPadding: units.largeSpacing
    topPadding: units.largeSpacing
    rightPadding: units.largeSpacing
    bottomPadding: units.largeSpacing

    background: Item {
        MouseArea {
            anchors.fill: parent
        }
        Rectangle {
            id: container
            color: Qt.rgba(PlasmaCore.ColorScope.backgroundColor.r, PlasmaCore.ColorScope.backgroundColor.g, PlasmaCore.ColorScope.backgroundColor.b, 0.85)
            anchors {
                fill: parent
                leftMargin: units.smallSpacing
                rightMargin: units.smallSpacing
                topMargin: units.smallSpacing
                bottomMargin: units.smallSpacing
            }
            radius: units.smallSpacing
        }
    }
}
