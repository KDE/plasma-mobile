/*
 *   Copyright 2014 Aaron Seigo <aseigo@kde.org>
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

import QtQuick 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

MouseArea {
    id: root


    height: units.gridUnit * 2
    width: parent.width
    anchors.bottomMargin: 10
    drag.axis: Drag.XAxis
    drag.target: root

    property bool expanded: false
    property var textGradient: Gradient {
                GradientStop { position: 1.0; color: "#FF00000C" }
                GradientStop { position: 0.0; color: "#00000C00" }
            }
    property color textGradientOverlay: "#9900000C"

    Behavior on x {
        SpringAnimation { spring: 2; damping: 0.2 }
    }

    Behavior on height {
        SpringAnimation { spring: 5; damping: 0.3 }
    }

    onExpandedChanged: {
        if (expanded && body) {
            height = units.gridUnit * 4;
        } else {
            height = units.gridUnit * 2;
        }
    }

    onReleased: {
        if (drag.active) {
            if (x > width / 4 || x < width / -4) {
                notificationsModel.remove(index);
            } else {
                x = 0;
            }
        } else {
            expanded = !expanded;
        }
    }


    PlasmaCore.IconItem {
        id: icon
        width: units.iconSizes.medium
        height: width
        anchors.verticalCenter: parent.verticalCenter
        x: units.largeSpacing
        y: 0
        source: appIcon && appIcon.length > 0 ? appIcon : "im-user"
    }

    Item {
        id: rounded
        clip: true
        height: parent.height
        width: height / 2
        anchors {
            left: icon.right
            leftMargin: units.largeSpacing
        }

        Rectangle {
            id: roundedRect
            height: parent.height
            width: parent.width * 2
            radius: height //Math.max(height, units.gridUnit)
            anchors {
                left: parent.left
                top: parent.top
            }

            gradient: root.textGradient

            Rectangle {
                anchors.fill: parent
                radius: height / 2
                color: textGradientOverlay
            }
        }
    }

    Rectangle {
        id: summaryArea
        width: parent.width - icon.width - rounded.width - (units.largeSpacing * 2)
        height: parent.height
        anchors {
            left: rounded.right
            top: parent.top
        }

        gradient: root.textGradient
        Rectangle {
            anchors.fill: parent
            color: textGradientOverlay
        }

        Text {
            id: summaryText
            anchors.fill: parent
            clip: true
            horizontalAlignment: Qt.AlignLeft
            verticalAlignment: Qt.AlignVCenter
            color: "white"
            text: summary + (root.expanded ? (body ? "\n" + body : '') :
                                             (body ? '...' : ''))
        }

    }

    Rectangle {
        id: extraArea
        width: parent.width
        height: parent.width
        anchors {
            left: summaryArea.right
            top: parent.top
        }

        gradient: root.textGradient
        Rectangle {
            anchors.fill: parent
            color: textGradientOverlay
        }
    }
}