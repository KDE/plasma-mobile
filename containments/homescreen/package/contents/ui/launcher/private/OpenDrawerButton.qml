/*
 *  Copyright 2019 Marco Martin <mart@kde.org>
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

import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.draganddrop 2.0 as DragDrop

import org.kde.plasma.private.containmentlayoutmanager 1.0 as ContainmentLayoutManager 

import org.kde.phone.homescreen 1.0

import org.kde.plasma.private.mobileshell 1.0 as MobileShell


MouseArea {
    id: arrowUpIcon
    z: 9
    property Flickable flickable
    property real factor: 0

    height: units.iconSizes.medium
    signal openRequested
    signal closeRequested

    onClicked: {
        if ((arrowUpIcon.flickable.contentY + arrowUpIcon.flickable.originY + arrowUpIcon.flickable.height*2) >= arrowUpIcon.flickable.height/2) {
            closeRequested();
        } else {
            openRequested();
        }
        scrollAnim.restart();
    }

    Item {
        anchors.centerIn: parent

        width: units.iconSizes.medium
        height: width

        Rectangle {
            anchors {
                verticalCenter: parent.verticalCenter
                right: parent.horizontalCenter
                left: parent.left
                verticalCenterOffset: -arrowUpIcon.height/4 + (arrowUpIcon.height/4) * arrowUpIcon.factor
            }
            color: theme.backgroundColor
            transformOrigin: Item.Right
            rotation: -45 + 90 * arrowUpIcon.factor
            antialiasing: true
            height: 1
        }
        Rectangle {
            anchors {
                verticalCenter: parent.verticalCenter
                left: parent.horizontalCenter
                right: parent.right
                verticalCenterOffset: -arrowUpIcon.height/4 + (arrowUpIcon.height/4) * arrowUpIcon.factor
            }
            color: theme.backgroundColor
            transformOrigin: Item.Left
            rotation: 45 - 90 * arrowUpIcon.factor
            antialiasing: true
            height: 1
        }
    }
}

