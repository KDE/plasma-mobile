/*
 *   Copyright 2011 Marco Martin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
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

import Qt 4.7
import org.kde.plasma.core 0.1 as PlasmaCore

Item {
    id: button
    property QtObject svg: iconsSvg
    property alias elementId: icon.elementId
    visible: action&&action.enabled
    property QtObject action
    property bool backgroundVisible: true
    width: backgroundVisible?actionSize+8:actionSize
    height: width

    PlasmaCore.Svg {
        id: buttonSvg
        imagePath: "widgets/actionbutton"
    }

    PlasmaCore.SvgItem {
        id: shadowItem
        svg: buttonSvg
        elementId: "shadow"
        anchors.fill: parent
        visible: backgroundVisible
    }

    PlasmaCore.SvgItem {
        id: buttonItem
        svg: buttonSvg
        elementId: "normal"
        anchors.fill: parent
        visible: backgroundVisible
    }

    PlasmaCore.SvgItem {
        id: icon
        width: actionSize
        height: actionSize
        svg: button.svg
        anchors.fill: buttonItem
        anchors.margins: backgroundVisible?8:0

        MouseArea {
            anchors.fill: parent
            anchors.leftMargin: -10
            anchors.topMargin: -10
            anchors.rightMargin: -10
            anchors.bottomMargin: -10
            onPressed: {
                buttonItem.elementId = "pressed"
                shadowItem.opacity = 0
            }
            onReleased: {
                buttonItem.elementId = "normal"
                shadowItem.opacity = 1
            }
            onClicked: {
                action.trigger()
            }
        }
    }

}
