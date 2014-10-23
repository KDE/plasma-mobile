/*
 *   Copyright 2014 Marco Martin <notmart@gmail.com>
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
import QtQuick.Window 2.0

Window {
    id: window
    flags: Qt.WindowDoesNotAcceptFocus

    property int offset: 0

    color: "transparent"

    MouseArea {
        width: window.width
        height: window.height
        state: "closed"

        property int startY: 0
        property int startOffset: 0;
        onPressed: {
            startY = mouse.y;
            startOffset = window.offset;
        }
        onPositionChanged: {
            window.offset = Math.min(height, startOffset + (mouse.y - startY));
        }

        Rectangle {
            width: window.width
            height: window.height
            y: -height + window.offset

            color: Qt.rgba(0, 0, 0, 0.8)
        }
    }


}
