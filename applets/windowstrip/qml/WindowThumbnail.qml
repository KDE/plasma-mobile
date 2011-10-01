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
 *   GNU Library General Public License for more details
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
    //space for the close button
    width: height*1.6 + 48
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
        anchors.topMargin: 4

        text: model["visibleName"]
        elide: Text.ElideRight
        color: theme.textColor
        width: parent.width - 40
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

    PlasmaCore.FrameSvgItem {
        imagePath: "widgets/button"
        prefix: "shadow"
        width: closeButton.width + margins.left + margins.right
        height: closeButton.height + margins.top + margins.bottom
        visible: model["actionClose"] && (model["className"] != shellName)
        anchors {
            top: parent.top
            right: parent.right
            topMargin: 32
        }

        PlasmaCore.FrameSvgItem {
            id: closeButton
            imagePath: "widgets/button"
            prefix: "normal"
            //a bit more left margin
            width: closeButtonSvg.width + margins.left + margins.right + 16
            height: closeButtonSvg.height + margins.top + margins.bottom
            x: parent.margins.left
            y: parent.margins.top

            MobileComponents.ActionButton {
                id: closeButtonSvg
                svg: iconsSvg
                iconSize: 22
                backgroundVisible: false
                elementId: "close"

                anchors {
                    verticalCenter: parent.verticalCenter
                    right: parent.right
                    rightMargin: parent.margins.right
                }

                onClicked: {
                    var service = tasksSource.serviceForSource(winId)
                    var operation = service.operationDescription("close")

                    service.startOperationCall(operation)
                }
            }
        }
    }
}
