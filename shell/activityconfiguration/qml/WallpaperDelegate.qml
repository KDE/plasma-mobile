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

Item {
    width: wallpapersList.delegateWidth
    height: wallpapersList.delegateHeight

    z: wallpapersList.currentIndex == index?900:0

    property alias screenshotPixmap: screenshotItem.pixmap
    property alias wallpaperName: nameText.text

    Rectangle {
        radius: 4
        scale: wallpapersList.currentIndex == index?1.06:1
        Behavior on scale {
                NumberAnimation {
                    duration: 250
                    easing.type: Easing.InOutQuad
                }
            }
        anchors {
            fill: parent
            margins: 4
        }

        QPixmapItem {
            id: screenshotItem
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
                width: nameText.paintedWidth
                height: nameText.paintedHeight
                Text {
                    id: nameText
                    text: display
                }
            }

        }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                wallpapersList.currentIndex = index
            }
        }
    }
}
