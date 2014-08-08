/*
 *   Copyright 2011 Marco Martin <mart@kde.org>
 *   Copyright 2011 Sebastian Kügler <sebas@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2 or
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
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kquickcontrolsaddons 2.0
import org.kde.plasma.mobilecomponents 0.2 as MobileComponents
import org.kde.plasma.components 2.0 as PlasmaComponents


Item {
    id: resourceItem
    anchors.horizontalCenter: parent.horizontalCenter


    Item {
        anchors {
            top: parent.top
            bottom: parent.bottom
        }
        width: Math.min(resourceItem.width, height * 1.6)

        PlasmaCore.FrameSvgItem {
            id: previewFrame
            imagePath: "widgets/media-delegate"
            prefix: "picture"

            height: previewImage.height + previewImage.anchors.topMargin + previewImage.anchors.bottomMargin
            width: previewImage.width + previewImage.anchors.leftMargin + previewImage.anchors.rightMargin
            anchors.centerIn: previewImage
        }

        QIconItem {
            id: previewImage
            visible: previewFrame.visible
            icon: url

            anchors {
                fill: parent

                leftMargin: Math.round(Math.min(previewFrame.margins.left, parent.height/6))
                topMargin: Math.round(Math.min(previewFrame.margins.top, parent.height/6))
                rightMargin: Math.round(Math.min(previewFrame.margins.right, parent.height/6))
                bottomMargin: Math.round(Math.min(previewFrame.margins.bottom, parent.height/6))
            }
        }
    }


    Column {
        anchors.centerIn: parent
        width: resourceItem.width
        visible: !previewFrame.visible

        QIconItem {
            id: iconItem
            height: roundToStandardSize(delegateItem.height - previewLabel.height)
            width: height
            anchors {
                horizontalCenter: parent.horizontalCenter
            }
<<<<<<< HEAD
            icon: decoration
=======
            icon: "image-x-generic"
>>>>>>> Add Baloo support to Widget Explorer
        }

        PlasmaComponents.Label {
            id: previewLabel
            text: display
            height: paintedHeight

            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
            anchors {
                horizontalCenter: parent.horizontalCenter
            }
            width: resourceItem.width
            style: Text.Outline
            styleColor: Qt.rgba(1, 1, 1, 0.6)
        }
    }
}

