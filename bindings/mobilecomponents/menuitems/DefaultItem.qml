/*
 *   Copyright 2011 Marco Martin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2 or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 1.0
import org.kde.plasma.core 0.1 as PlasmaCore


Text {
    id: menuItem
    font.pointSize: 14
    horizontalAlignment: Text.AlignHCenter
    property int implicitWidth: paintedWidth
    property int implicitHeight: paintedHeight

    text: label

    PlasmaCore.Theme {
        id: theme
    }
    color: theme.textColor

    function run(x, y)
    {
        print("ITEM RUN: "+label+ " " + x + " " + y)
        var controller = metadataSource.serviceForSource(sourceName)
        var operation = controller.operationDescription(operationName)
        operation.ResourceUrl = resourceUrl
        controller.startOperationCall(operation)
    }
}
