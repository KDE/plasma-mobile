/*
 *   Copyright 2010 Marco Martin <notmart@gmail.com>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
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

import Qt 4.7
import org.kde.plasma.graphicswidgets 0.1 as PlasmaWidgets
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.qtextracomponents 0.1
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents

Rectangle {
    radius: 4
    width: (wallpapersList.height-4)*1.6
    height: wallpapersList.height-4

    QPixmapItem {
        pixmap: screenshot
        anchors {
            fill: parent
            margins: 6
        }
        Rectangle {
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            color: Qt.rgba(1,1,1,0.6)
            radius: 4
            width: wallpaperName.paintedWidth
            height: wallpaperName.paintedHeight
            Text {
                id: wallpaperName
                text: display
            }
        }
        Rectangle {
            opacity:wallpapersList.currentIndex == index?1:0
            width:10
            height:10
            radius:5
            anchors.top:parent.top
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
    MouseArea {
        anchors.fill: parent
        onClicked: wallpapersList.currentIndex = index
    }
}
