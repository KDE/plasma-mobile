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

import QtQuick 1.0
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.qtextracomponents 0.1
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents
 
Item {
    id: resourceItem
    anchors.fill: parent

    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        QIconItem {
            id: previewImage
            height: 64
            width: 64
            anchors.margins: 0
            anchors.horizontalCenter: parent.horizontalCenter

            function resourceIcon(resourceTypes) {
                if (mimeType) {
                    return mimeType.replace("/", "-")
                }
                return "nepomuk"
            }

            icon: {
                // FIXME: remove this crap, fix icon in metadata data set
                try {
                    if (model["iconName"]) {
                        return QIcon(model["iconName"])
                    //check if model["icon"] is a QIcon
                    } else if (model["icon"] && model["icon"].addPixmap) {
                        return model["icon"]
                    } else if (model["icon"]) {
                        return QIcon(model["icon"])
                    }
                    if (!model["hasSymbol"] && decoration) {
                        return decoration
                    }
                    var _l = hasSymbol.toString().split(",");
                    if (_l.length == 1) {
                        return QIcon(hasSymbol);
                    } else if (_l.length > 1) {
                        // pick the last one
                        var _i = _l[_l.length-1];
                        return QIcon(_i);
                    } else {
                        //print("HHH types" + types.toString());
                        resourceIcon(types.toString())
                    }
                    //print("icon:" + hasSymbol);
                } catch(e) {
                    var _i = resourceIcon(className);
                    print("fallback icon: " + _i + e);
                    return QIcon(_i);
                    print("icon2:" + _i);
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
                //top: previewImage.bottom
                horizontalCenter: parent.horizontalCenter
            }
            width: resourceItem.width
            style: Text.Outline
            styleColor: Qt.rgba(1, 1, 1, 0.6)
        }

        Text {
            id: infoLabel
            //image: metadataSource.data[DataEngineSource]["fileName"]
            //text: "the long and winding road..."
            text: className
            opacity: 0.8
            //font.pixelSize: font.pixelSize * 1.8
            font.pixelSize: 12
            height: 14
            width: parent.width - previewImage.width
            //wrapMode: Text.Wrap
            //anchors.top: previewLabel.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            visible: infoLabelVisible
        }
    }
}
