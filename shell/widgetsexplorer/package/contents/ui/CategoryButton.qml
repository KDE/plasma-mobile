/*
 *   Copyright 2010 Marco Martin <notmart@gmail.com>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
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
import org.kde.plasma.components 0.1 as PlasmaComponents
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents


MouseArea {
    id: root
    width: 140
    height: 120
    property Component component
    property alias text: label.text
    property string icon
    property string resourceType
    visible: String(resourceType).charAt(0) == "_" || cloudModel.categories.indexOf(resourceType) != -1

    MobileComponents.IconButton {
        id: iconButton
        icon: root.icon
        onClicked: {
            stack.push(component)
        }
    }
    PlasmaComponents.Label {
        id: label
        anchors {
            top: iconButton.bottom
            horizontalCenter: iconButton.horizontalCenter
        }
    }
}

