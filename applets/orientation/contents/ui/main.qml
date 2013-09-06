// -*- coding: iso-8859-1 -*-
/*
 *   Copyright 2012 Jeremy Whiting <jpwhiting@kde.org>
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

import QtQuick 1.1
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.mobilecomponents 0.1

Item {
    id: orientation
    width: button.width
    height: button.height
    property int minimumWidth: button.width
    property int minimumHeight: button.height
    property int maximumWidth: button.width
    property int maximumHeight: button.height

    PlasmaCore.DataSource {
        id: orientationSource
        engine: "org.kde.active.screenorientation"
        connectedSources: sources
        interval: 0
    }

    IconButton {
        id: button
        width: theme.mediumIconSize
        height: theme.mediumIconSize
        icon: (orientationSource.data["Screen0"]["Rotation"] == 1) ? QIcon("object-rotate-left") : QIcon("object-rotate-right")

        onClicked: {
            var sources = orientationSource.sources
            var service = orientationSource.serviceForSource(sources[0])
            var operation
            if (orientationSource.data["Screen0"]["Rotation"] == 1) {
                operation = service.operationDescription("setRotation")
                operation["rotation"] = 2
            } else {
                operation = service.operationDescription("setRotation")
                operation["rotation"] = 1
            }
            service.startOperationCall(operation)
        }
    }
}
