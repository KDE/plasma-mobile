// -*- coding: iso-8859-1 -*-
/*
 *   Author: Marco Martin <mart@kde.org>
 *   Date: Sun Nov 7 2010, 18:51:24
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
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents
import org.kde.qtextracomponents 0.1

Item {
    id: windowDelegate
    width: height*1.6
    height: main.height
    onHeightChanged: {
        positionsTimer.restart()
    }
    property string winId: DataEngineSource

    Rectangle {
        opacity: 0
        anchors.fill: parent
    }

    QIconItem {
        anchors.centerIn: parent
        width: 64
        height: 64
        icon: model["icon"]
    }

    Text {
        id: windowTitle
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter;
        text: model["visibleName"]
        elide: Text.ElideMiddle
        color: theme.textColor
        width: parent.width
        horizontalAlignment: Text.AlignHCenter
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            //print(winId)
            var service = tasksSource.serviceForSource(winId)
            var operation = service.operationDescription("activate")

            service.startOperationCall(operation)
        }
    }

    MobileComponents.ActionButton {
        id: closeButton
        svg: iconsSvg
        iconSize: 22
        elementId: "close"
        visible: model["actionClose"]&&(model["className"] != shellName)

        anchors {
            top: parent.top
            right: parent.right
        }

        onClicked: {
            var service = tasksSource.serviceForSource(winId)
            var operation = service.operationDescription("close")

            service.startOperationCall(operation)
        }
    }
}
