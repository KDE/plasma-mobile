/*
 *   Copyright 2011 Marco Martin <mart@kde.org>
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
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents
import org.kde.qtextracomponents 0.1

Rectangle {
    id: quickBrowserBar
    property alias model: thumbnailsView.model

    function setCurrentIndex(index)
    {
        thumbnailsView.positionViewAtIndex(index, ListView.Center)
        thumbnailsView.currentIndex = index
    }

    z: 9999
    color: Qt.rgba(1, 1, 1, 0.7)

    anchors {
        left: parent.left
        right: parent.right
    }

    height: 65

    ListView {
        id: thumbnailsView
        spacing: 1
        anchors {
            fill: parent
            topMargin: 1
        }
        orientation: ListView.Horizontal

        delegate: Item {
            id: delegate
            z: index == thumbnailsView.currentIndex ? 200 : 0
            scale: index == thumbnailsView.currentIndex ? 1.4 : 1
            Behavior on scale {
                NumberAnimation {
                    duration: 250
                    easing.type: Easing.InOutQuad
                }
            }
            width: height*1.6
            height: thumbnailsView.height
            Rectangle {
                width: (index == thumbnailsView.currentIndex) ? thumbnailImage.width + 10 : thumbnailImage.width
                height: (index == thumbnailsView.currentIndex) ? thumbnailImage.height + 10 : thumbnailImage.height
                anchors.centerIn: parent
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
            }
            QImageItem {
                id: thumbnailImage
                anchors.centerIn: parent
                width: {
                        if (nativeWidth/nativeHeight >= parent.width/parent.height) {
                            return parent.width
                        } else {
                            return parent.height * (nativeWidth/nativeHeight)
                        }
                    }
                height: {
                    if (nativeWidth/nativeHeight >= parent.width/parent.height) {
                        return parent.width / (nativeWidth/nativeHeight)
                    } else {
                        return parent.height
                    }
                }

                image: thumbnail

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        thumbnailsView.currentIndex = index
                        viewerPage.setCurrentIndex(index)
                    }
                }
            }
        }
    }
}
