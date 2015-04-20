/*
 *   Copyright 2014 Aaron Seigo <aseigo@kde.org>
 *   Copyright 2014 Marco Martin <mart@kde.org>
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

import QtQuick 2.4
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.nemomobile.voicecall 1.0

MouseArea {
    id: root

    signal accepted
    signal rejected

    Layout.minimumHeight: units.gridUnit * 5
    Layout.fillWidth: true
    property int handlePosition: (answerHandle.x + answerHandle.width/2)
    drag {
        target: answerHandle
        axis: Drag.XAxis
        minimumX: 0
        maximumX: width - answerHandle.width
    }
    Rectangle {
        anchors.fill: parent
        radius: height
        color: Qt.rgba((handlePosition > root.width/2 ? 0.6 : 0)+0.2, (handlePosition < root.width/2 ? 0.6 : 0)+0.2, 0.2, Math.abs(handlePosition - (root.width/2)) / answerHandle.width/2);
        Rectangle {
            id: answerHandle
            x: parent.width/2 - width/2
            height: parent.height
            width: height
            radius: width
            color: Qt.rgba(0.2, 0.8, 0.2, 1)
            PlasmaCore.IconItem {
                source: "call-start"
                width: parent.width * 0.7
                height: width
                anchors.centerIn: parent
            }
            Behavior on x {
                enabled: root.pressed
                XAnimator {
                    duration: units.longDuration
                    easing.type: Easing.InOutQuad
                }
            }
        }
    }
    onReleased: {
        if (answerHandle.x <= answerHandle.width) {
            root.accepted();
        } else if (answerHandle.x + answerHandle.width >= root.width - answerHandle.width) {
            root.rejected();
        }

        answerHandle.x = width/2 - answerHandle.width/2
    }
}
