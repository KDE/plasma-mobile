/*
 *   Copyright 2014 Aaron Seigo <aseigo@kde.org>
 *   Copyright 2017 Marco Martin <notmart@gmail.com>
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

import QtQuick 2.6
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

MouseArea {
    id: handle
    z: 999

    property bool mirrored: false
    anchors {
        top: parent.top
        bottom: parent.bottom
        right: handle.mirrored ? parent.right : undefined
        left: handle.mirrored ? undefined : parent.left
    }
    property Item frame: nextActivityLabel
    width: units.gridUnit
    drag.target: nextActivityLabel
    drag.axis: Drag.XAxis
    property real position: (mirrored ? -1 : 1) * (nextActivityLabel.x + nextActivityLabel.width/2) / (parent.width/2)
    PlasmaCore.FrameSvgItem {
        id: nextActivityLabel
        anchors.verticalCenter: parent.verticalCenter
        x: handle.mirrored ? handle.width : -width
        opacity: parent.position
        imagePath: "widgets/background"
        width: childrenRect.width + units.gridUnit*2
        height: childrenRect.height + units.gridUnit*2
        PlasmaComponents.Label {
            anchors.centerIn: parent
            text: handle.mirrored ? i18n("Go To Next Activity") : i18n("Go To Previous Activity")
        }
    }
    onPressed: {
        nextActivityLabel.x = handle.mirrored ? handle.width : -nextActivityLabel.width
    }
    onReleased: {
        if (position > 0.5) {
            if (handle.mirrored) {
                root.containmentsEnterFromRight = true;
                activitiesRepresentation.incrementCurrentIndex();
            } else {
                root.containmentsEnterFromRight = false;
                activitiesRepresentation.decrementCurrentIndex();
            }
            acceptAnim.running = true;
        } else {
            dismissAnim.running = true;
        }
    }
    OpacityAnimator {
        id: acceptAnim
        target: nextActivityLabel
        from: nextActivityLabel.opacity
        to: 0
        duration: units.longDuration
        easing.type: Easing.InOutQuad
    }
    XAnimator {
        id: dismissAnim
        target: nextActivityLabel
        from: nextActivityLabel.x
        to: handle.mirrored ? 0 : -nextActivityLabel.width
        duration: units.longDuration
        easing.type: Easing.InOutQuad
    }
}

