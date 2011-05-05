/*
 *   Copyright 2011 Marco Martin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2 or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 1.0
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents

Rectangle {
    id: background
    anchors.fill: parent
    color: Qt.rgba(0,0,0,0.4)

    MouseArea {
        anchors.fill:parent
        onClicked: background.visible = false
    }

    property Item delegate
    onDelegateChanged: {
        var menuPos = delegate.mapToItem(parent, delegate.width/2-menuFrame.width/2, delegate.height)
        menuFrame.x = menuPos.x
        menuFrame.y = menuPos.y
    }

    PlasmaCore.FrameSvgItem {
        id: menuFrame
        imagePath: "dialogs/background"
        width: entriesColumn.width + margins.left + margins.right
        height: entriesColumn.height + margins.top + margins.bottom

        Column {
            id: entriesColumn
            x: menuFrame.margins.left
            y: menuFrame.margins.top
            Text {
                text: "Share on Dropbox"
            }
            Text {
                text: "Add to current Activity"
            }
        }
    }
}
