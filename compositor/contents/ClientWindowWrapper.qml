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
    MouseArea {
        z: 99
        anchors.fill: parent
        enabled: compositorRoot.layers.windows.switchMode
        onClicked: {
            compositorRoot.currentWindow = window
        }

        PlasmaCore.IconItem {
            anchors {
                right: parent.right
                bottom: parent.bottom
            }
            visible: compositorRoot.layers.windows.switchMode
            colorGroup: PlasmaCore.Theme.ComplementaryColorGroup
            width: units.iconSizes.smallMedium
            height: width
            source: "window-close"

            MouseArea {
                anchors.fill: parent
                onClicked: window.close()
            }
        }
    }
}
