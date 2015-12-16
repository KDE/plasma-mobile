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
import QtQuick.Controls 1.3
import QtQuick.Layouts 1.2
import org.kde.plasma.mobilecomponents 0.2

ScrollView {
    id: root
    property bool requestingRefresh: false
    signal refreshRequested

    children: [
        Item {
            z: 99
            y: -root.flickableItem.contentY-height
            width: root.flickableItem.width
            height: Units.gridUnit * 3
            BusyIndicator {
                anchors.centerIn: parent
                running: root.requestingRefresh
                visible: root.requestingRefresh || parent.y < Units.gridUnit
                opacity: root.requestingRefresh ? 1 : (root.flickableItem.originY - root.flickableItem.contentY) / (Units.gridUnit * 3)
                rotation: root.requestingRefresh ? 0 : 360 * opacity
            }
            onYChanged: {
                if (y > Units.gridUnit) {
                    return;
                }
                if (!root.requestingRefresh && y > 0) {
                    root.requestingRefresh = true;
                    root.refreshRequested();
                }
            }
            Connections {
                target: root.flickableItem
                onContentHeightChanged: {
                    root.flickableItem.bottomMargin = Math.max((root.height - root.flickableItem.contentHeight), Units.gridUnit * 5);
                }
            }
        }
    ]

    onHeightChanged: {
        root.flickableItem.bottomMargin = (root.height - root.flickableItem.contentHeight);
        root.flickableItem.topMargin = height/2;
    }
}
