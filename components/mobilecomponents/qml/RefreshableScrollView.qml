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
    property bool refreshing: false

    children: [
        Item {
            z: 99
            y: -root.flickableItem.contentY-height
            width: root.flickableItem.width
            height: root.flickableItem.topMargin
            BusyIndicator {
                id: busyIndicator
                anchors.centerIn: parent
                running: root.refreshing
                visible: root.refreshing || parent.y < root.flickableItem.topMargin
                opacity: root.refreshing ? 1 : (parent.y/(busyIndicator.height*2))
                rotation: root.refreshing ? 0 : 360 * opacity
            }
            Rectangle {
                color: Theme.textColor
                opacity: 0.2
                anchors {
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }
                height: 1
            }
            onYChanged: {
                if (!root.refreshing && y > busyIndicator.height*2) {
                    root.refreshing = true;
                }
            }
            Binding {
                target: root.flickableItem
                property: "bottomMargin"
                value: Math.max((root.height - root.flickableItem.contentHeight), Units.gridUnit * 5)
            }

            Binding {
                target: root.flickableItem
                property: "topMargin"
                value: height/2
            }
        }
    ]
}
