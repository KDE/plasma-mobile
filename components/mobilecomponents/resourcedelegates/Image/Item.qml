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

Item {
    id: resourceItem
    anchors.fill: parent

    Item {
        id: itemFrame
        anchors {   bottom: parent.bottom;
                    top: parent.top;
                    left: parent.left;
                    right: parent.right;
                    margins: 24;
        }
        height: resourceItem.height

        QIconItem {
            id: previewImage
            height: 64
            width: 64
            anchors.margins: 8
            icon: decoration
        }

        Text {
            id: previewLabel
            text: display
            //text: url
            font.pixelSize: units.iconSizes.small
            font.bold: true
            wrapMode: Text.Wrap
            color: theme.textColor
            anchors.top: itemFrame.top
            anchors.left: previewImage.right
            anchors.right: itemFrame.right
            anchors.margins: 8
        }

        Text {
            id: infoLabel
            text: display
            color: theme.textColor
            opacity: 0.8
            font.pixelSize: units.iconSizes.small
            height: 14
            width: parent.width - previewImage.width
            anchors.right: itemFrame.right
            anchors.top: previewLabel.bottom
            anchors.bottom: itemFrame.bottom
            anchors.left: previewImage.right
            anchors.margins: 8
        }
    }
}
