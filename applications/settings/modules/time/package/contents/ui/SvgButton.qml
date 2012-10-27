// -*- coding: iso-8859-1 -*-
/*
 *   Copyright 2011 Sebastian Kügler <mart@kde.org>
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

Item {
    id: svgButton
    objectName: "svgButton"
    width: 48
    height: 48
    property Item targetItem

    MobileComponents.ActionButton {
        id: closeButtonSvg
        svg: iconsSvg
        iconSize: 22
        backgroundVisible: false
        elementId: "close"

        anchors {
            //verticalCenter: parent.verticalCenter
            centerIn: parent
            //right: parent.right
            //rightMargin: parent.margins.right
        }

        onClicked: {
            targetItem.state = "closed";
        }
    }
}
