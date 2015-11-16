/*
 *   Copycontext 2015 Marco Martin <mart@kde.org>
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

import QtQuick 2.1
import org.kde.plasma.mobilecomponents 0.2 as MobileComponents
import org.kde.plasma.core 2.0 as PlasmaCore

MobileComponents.IconGrid {
    id: root

    model: PlasmaCore.DataModel {
        dataSource: PlasmaCore.DataSource {
            engine: "apps"
            connectedSources: sources
        }
    }
    delegate: Item {
        width: root.delegateWidth
        height: root.delegateHeight
        Rectangle {
            anchors {
                fill: parent
                margins: units.gridUnit
            }
            color: "red"
            MobileComponents.Label {
                text: model.name
            }
        }
    }
}
