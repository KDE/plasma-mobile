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
    width: buttonColumn.width
    height: buttonColumn.height
    property int minimumWidth: buttonColumn.width
    property int minimumHeight: buttonColumn.height
    property int maximumWidth: buttonColumn.width
    property int maximumHeight: buttonColumn.height

    PlasmaCore.DataSource {
        id: orientationSource
        engine: "orientation"
        interval: 0
    }

    Component.onCompleted: {
        plasmoid.setPopupIconByName("transform-rotate")
    }

    Column {
        id: buttonColumn
        spacing: 5
        IconButton {
            width: theme.mediumIconSize
            height: theme.mediumIconSize
            icon: QIcon("object-rotate-left")

            onClicked: {
                var sources = orientationSource.sources
                var service = orientationSource.serviceForSource(sources[0])
                var operation = service.operationDescription("rotateLeft")
                service.startOperationCall(operation)
            }
        }

        IconButton {
            icon: QIcon("object-rotate-right")
            width: 32
            height: 32
            onClicked: {
                var sources = orientationSource.sources
                var service = orientationSource.serviceForSource(sources[0])
                var operation = service.operationDescription("rotateRight")
                service.startOperationCall(operation)
            }
        }
    }
}
