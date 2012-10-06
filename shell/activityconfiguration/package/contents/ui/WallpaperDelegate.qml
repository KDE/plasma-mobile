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
 *   GNU Library General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 1.0
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.qtextracomponents 0.1
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents

Item {
    id: root
    width: wallpapersList.delegateWidth
    height: wallpapersList.delegateHeight

    z: wallpapersList.currentIndex == index?900:0

    property alias screenshotPixmap: screenshotItem.pixmap
    property alias wallpaperName: nameText.text

    Item {
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: nameText.top
        }
        PlasmaCore.FrameSvgItem {
            imagePath: "widgets/media-delegate"
            prefix: (wallpapersList.currentIndex - (wallpapersList.currentPage*wallpapersList.pageSize)) == index ? "picture-selected" : "picture"

            Behavior on width {
                    NumberAnimation {
                        duration: 250
                        easing.type: Easing.InOutQuad
                    }
                }
            Behavior on height {
                    NumberAnimation {
                        duration: 250
                        easing.type: Easing.InOutQuad
                    }
                }
            anchors.centerIn: parent
            width: (wallpapersList.currentIndex - (wallpapersList.currentPage*wallpapersList.pageSize)) == index ? parent.width+5 : parent.width-16

            height: (wallpapersList.currentIndex - (wallpapersList.currentPage*wallpapersList.pageSize)) == index ? parent.height+5 : parent.height-16

            QPixmapItem {
                id: screenshotItem
                pixmap: screenshot
                anchors {
                    fill: parent
                    leftMargin: parent.margins.left
                    topMargin: parent.margins.top
                    rightMargin: parent.margins.right
                    bottomMargin: parent.margins.bottom
                }
            }
        }
    }

    Text {
        id: nameText
        text: display

        anchors {
            left: parent.left
            right: parent.right
            rightMargin: 12
            leftMargin: 12
            bottom:parent.bottom
            bottomMargin: 8
        }
        font.pixelSize: 14
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
        style: Text.Outline
        styleColor: Qt.rgba(1, 1, 1, 0.6)
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            inputPanelController.closeSoftwareInputPanel()
            wallpapersList.currentIndex = (wallpapersList.currentPage*wallpapersList.pageSize) + index
        }
    }
}
