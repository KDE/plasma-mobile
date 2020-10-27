/*
 *  Copyright 2015 Marco Martin <mart@kde.org>
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

import QtQuick 2.1
import QtQuick.Layouts 1.1

import MeeGo.QOfono 0.2

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

Item {
    width: strengthIcon.height + strengthLabel.width
    Layout.minimumWidth: strengthIcon.height + strengthLabel.width

    OfonoManager {
        id: ofonoManager
    }

    OfonoNetworkRegistration {
        id: netreg
        Component.onCompleted: {
            netreg.scan()
        }

        modemPath: ofonoManager.modems.length ? ofonoManager.modems[0] : ""
    }

    OfonoSimManager {
        id: simManager
        modemPath: ofonoManager.modems.length ? ofonoManager.modems[0] : ""
    }

    PlasmaCore.IconItem {
        id: strengthIcon
        colorGroup: PlasmaCore.ColorScope.colorGroup
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: height
        height: parent.height

        source: netreg.strength == 100 ? "network-mobile-100"
                : netreg.strength >= 80 ? "network-mobile-80"
                : netreg.strength >= 60 ? "network-mobile-60"
                : netreg.strength >= 40 ? "network-mobile-40"
                : netreg.strength >= 20 ? "network-mobile-20"
                : "network-mobile-0"
    }

    PlasmaComponents.Label {
        id: label
        anchors.left: strengthIcon.right
        anchors.verticalCenter: parent.verticalCenter

        text: simManager.pinRequired !== OfonoSimManager.NoPin ? i18n("Sim locked") : netreg.name
        color: PlasmaCore.ColorScope.textColor
        font.pixelSize: parent.height / 2
    }
}
