/*
 *   Copyright 2015 Marco Martin <mart@kde.org>
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

import QtQuick 2.1
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import org.kde.plasma.mobilecomponents 0.2

MouseArea {
    id: button
    property alias iconSource: icon.source
    Layout.minimumWidth: Units.iconSizes.large
    Layout.maximumWidth: Layout.minimumWidth
    implicitWidth: Units.iconSizes.large
    implicitHeight: width
    drag {
        target: button
        axis: Drag.XAxis
    }

    onReleased: {
        if (x > Math.min(parent.width/4*3, parent.width/2 + globalDrawer.drawer.width/2)) {
            globalDrawer.open();
            contextDrawer.close();
        } else if (x < Math.max(parent.width/4, parent.width/2 - contextDrawer.drawer.width/2)) {
            contextDrawer.open();
            globalDrawer.close();
        } else {
            globalDrawer.close();
            contextDrawer.close();
        }
    }
    Connections {
        target: globalDrawer
        onPositionChanged: {
            if (!button.pressed) {
                button.x = globalDrawer.drawer.width * globalDrawer.position + button.parent.width/2 - button.width/2;
            }
        }
    }
    Connections {
        target: contextDrawer
        onPositionChanged: {
            if (!button.pressed) {
                button.x = button.parent.width/2 - button.width/2 - contextDrawer.drawer.width * contextDrawer.position;
            }
        }
    }
    onXChanged: {
        if (button.pressed) {
            globalDrawer.position = Math.min(1, Math.max(0, (x - button.parent.width/2 + button.width/2)/globalDrawer.drawer.width));
            contextDrawer.position = Math.min(1, Math.max(0, (button.parent.width/2 - button.width/2 - x)/contextDrawer.drawer.width));
        }
    }
    Rectangle {
        id: background
        radius: width/2
        width: parent.width
        height: parent.height
        color: button.pressed ? Theme.highlightColor : Theme.backgroundColor
        Icon {
            id: icon
            anchors {
                fill: parent
                margins: units.smallSpacing
            }
        }
        Behavior on color {
            ColorAnimation {
                duration: units.longDuration
                easing.type: Easing.InOutQuad
            }
        }
        Behavior on x {
            NumberAnimation {
                duration: units.longDuration
                easing.type: Easing.InOutQuad
            }
        }
    }
    DropShadow {
        anchors.fill: background
        horizontalOffset: 0
        verticalOffset: units.smallSpacing/2
        radius: units.gridUnit / 2.4
        samples: 16
        color: button.pressed ? "transparent" : Qt.rgba(0, 0, 0, 0.5)
        source: background
    }
}

