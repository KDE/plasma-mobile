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

import QtQuick 2.4
import QtQuick.Layouts 1.1

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kquickcontrolsaddons 2.0

Item {
    id: button
    width: Math.min(parent.width, parent.height)
    height: width

    property MouseArea mouseArea
    readonly property bool pressed: mouseArea.pressed && mouseArea.activeButton == button
    property alias iconSource: icon.source
    signal clicked()

    Rectangle {
        radius: height/2
        anchors.fill: parent
        opacity: button.pressed && button.enabled ? 0.1 : 0
        color: PlasmaCore.ColorScope.textColor
        Behavior on opacity {
            //an OpacityAnimator causes stuttering in task switcher dragging
            NumberAnimation {
                duration: units.longDuration
                easing.type: Easing.InOutQuad
            }
        }
    }
    PlasmaCore.IconItem {
        id: icon
        anchors.fill: parent
        colorGroup: PlasmaCore.ColorScope.colorGroup
        //enabled: button.enabled && button.clickable
    }
}
