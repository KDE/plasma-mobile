/*
 *   Copyright 2014 Pier Luigi Fiorini <pierluigi.fiorini@gmail.com>
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

WindowWrapper {
    id: window
    objectName: "clientWindow"
    onXChanged: {
        if (compositorRoot.currentWindow == window) {
            compositorRoot.layers.windows.contentX = x;
        }
    }
    Behavior on y {
        enabled: !mouse.active
        SequentialAnimation {
            NumberAnimation {
                easing.type: "InOutQuad"
                duration: units.longDuration
            }
            ScriptAction {
                script: {
                    if (window.opacity < 0.3) {
                        window.close();
                    }
                }
            }
        }
    }
    opacity: 1 - (Math.abs(y) / height)

    MouseArea {
        id: mouse
        z: 99
        anchors.fill: parent
        enabled: compositorRoot.layers.windows.switchMode
        property bool active
        onPressed: {
            active = true;
        }
        onClicked: {
            compositorRoot.currentWindow = window
        }
        onReleased: {
            active = false;
            if (window.opacity < 0.3) {
                window.y = (window.y > 0 ? +1 : -1) * window.height;
            } else {
                window.y = 0;
            }
        }
        drag {
            axis: Drag.YAxis
            target: window
        }
    }
}
