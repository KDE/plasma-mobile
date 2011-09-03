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
    id: resourceItem
    anchors.fill: parent

    PlasmaCore.DataSource {
        id: pmSource
        engine: "preview"

        interval: 0
        Component.onCompleted: {
            pmSource.connectedSources = [url]
            if (data[url] == undefined) {
                previewFrame.visible = false
                return
            }
            previewFrame.visible = data[url]["status"] == "done"
            iconItem.visible = !previewFrame.visible
            previewImage.image = data[url]["thumbnail"]
        }
        onDataChanged: {
            previewFrame.visible = (data[url]["status"] == "done")
            iconItem.visible = !previewFrame.visible
            previewImage.image = data[url]["thumbnail"]
        }
    }

    Column {
        anchors.centerIn: parent

        Item {
            id: iconContainer
            height: resourceItem.height - previewLabel.height - infoLabel.height
            width: resourceItem.width

            QIconItem {
                id: iconItem
                width: 64
                height: 64
                anchors.centerIn: parent
                icon: model["mimeType"]?QIcon(mimeType.replace("/", "-")):QIcon("image-x-generic")
            }

            PlasmaCore.FrameSvgItem {
                id: previewFrame
                imagePath: "widgets/media-delegate"
                prefix: "picture"

                height: previewImage.height+margins.top+margins.bottom
                width: previewImage.width+margins.left+margins.right
                visible: false
                anchors.centerIn: previewArea
            }

            Item {
                id: previewArea
                anchors {
                    fill: parent

                    leftMargin: previewFrame.margins.left
                    topMargin: previewFrame.margins.top
                    rightMargin: previewFrame.margins.right
                    bottomMargin: previewFrame.margins.bottom
                }

                QImageItem {
                    id: previewImage
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
                }
            }
        }

        Text {
            id: previewLabel
            text: label

            font.pixelSize: 14
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
            anchors.horizontalCenter: parent.horizontalCenter
            width: 130
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
}
