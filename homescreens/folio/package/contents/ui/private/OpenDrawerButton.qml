/*
 *  SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
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

MouseArea {
    id: arrowUpIcon
    z: 9
    
    property Flickable flickable
    property real factor: 0

    cursorShape: Qt.PointingHandCursor
    height: PlasmaCore.Units.iconSizes.smallMedium
    signal openRequested
    signal closeRequested
    
    onClicked: {
        openRequested();
    }

    Item {
        anchors.centerIn: parent

        width: PlasmaCore.Units.iconSizes.smallMedium
        height: width

        Rectangle {
            anchors {
                verticalCenter: parent.verticalCenter
                right: parent.horizontalCenter
                left: parent.left
                verticalCenterOffset: -arrowUpIcon.height/4 + (arrowUpIcon.height/4) * arrowUpIcon.factor
            }
            color: "white"
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
            color: "white"
            transformOrigin: Item.Left
            rotation: 45 - 90 * arrowUpIcon.factor
            antialiasing: true
            height: 1
        }
    }
}

