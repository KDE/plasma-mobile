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

import QtQuick 1.1
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.qtextracomponents 0.1
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents

Column {
    id: resourceItem
    anchors.horizontalCenter: parent.horizontalCenter

    Item {
        id: iconContainer
        height: roundToStandardSize(delegateItem.height - previewLabel.height)
        width: resourceItem.width

        QIconItem {
            id: iconItem
            width: height
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: parent.top
                bottom: parent.bottom
            }
            icon: model["mimeType"]?QIcon(mimeType.replace("/", "-")):QIcon("image-x-generic")
            visible: !previewFrame.visible
        }

        PlasmaCore.FrameSvgItem {
            id: previewFrame
            imagePath: "widgets/media-delegate"
            prefix: "picture"

            height: previewImage.height + previewArea.anchors.topMargin + previewArea.anchors.bottomMargin
            width: previewImage.width + previewArea.anchors.leftMargin + previewArea.anchors.rightMargin
            visible: thumbnail != undefined
            anchors.centerIn: previewArea
        }

        Item {
            id: previewArea
            visible: previewFrame.visible
            anchors {
                fill: parent

                leftMargin: Math.round(Math.min(previewFrame.margins.left, parent.height/6))
                topMargin: Math.round(Math.min(previewFrame.margins.top, parent.height/6))
                rightMargin: Math.round(Math.min(previewFrame.margins.right, parent.height/6))
                bottomMargin: Math.round(Math.min(previewFrame.margins.bottom, parent.height/6))
            }

            QImageItem {
                id: previewImage
                anchors.centerIn: parent
                image: thumbnail == undefined ? null : thumbnail

                width: parent.height * (nativeWidth/nativeHeight)
                height: parent.height
            }
        }
    }

    Text {
        id: previewLabel
        text: label

        font.pixelSize: 14
        //wrapMode: Text.Wrap
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
        anchors {
            horizontalCenter: parent.horizontalCenter
        }
        width: resourceItem.width
        style: Text.Outline
        styleColor: Qt.rgba(1, 1, 1, 0.6)
    }

    Text {
        id: infoLabel
        text: className
        opacity: 0.8
        font.pixelSize: 12
        height: 14
        width: parent.width - iconItem.width
        anchors.horizontalCenter: parent.horizontalCenter
        visible: infoLabelVisible
    }
}

