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

import Qt 4.7
import org.kde.plasma.graphicswidgets 0.1 as PlasmaWidgets
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.qtextracomponents 0.1
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents
 
Item {
    id: resourceItem
    anchors.fill: parent

    PlasmaCore.Theme {
        id: theme
    }

    Item {
        id: itemFrame
        anchors {   bottom: parent.bottom;
                    top: parent.top;
                    left: parent.left;
                    right: parent.right;
                    margins: 24;
        }
        //height: 128
        height: resourceItem.height

        QIconItem {
            id: previewImage
            height: 64
            width: 64
            anchors.margins: 8

            function resourceIcon(resourceTypes) {
                var icons = new Object();
                icons["Resource"] = "nepomuk";
                icons["FileDataObject"] = "unknown";

                // Audio
                icons["Audio"] = "audio-x-generic";
                icons["MusicPiece"] = "audio-x-generic";

                // Images
                icons["Image"] = "image-x-generic";
                icons["RasterImage"] = "image-x-generic";

                icons["Email"] = "internet-mail";
                icons["PersonContact"] = "x-office-contact";
                icons["Document"] = "kword";

                // ... add some more

                // keep searching until the most specific icon is found
                var _icon = "nepomuk";
                var typeList = resourceTypes.split(",");

                for(var i = 0; i < typeList.length; i++) {
                    var shortType = typeList[i].split("#")[1];
                    for (key in icons) {
                        if (key == shortType) {
                            print("M: " + key + icons[shortType]);
                            _icon = icons[shortType];
                        }
                    }
                }
                return _icon;
            }

            Component.onCompleted: {
                try {
                    var _l = hasSymbol.toString().split(",");
                    if (_l.length == 1) {
                        icon = QIcon(hasSymbol);
                    } else if (_l.length > 1) {
                        // pick the last one
                        var _i = _l[_l.length-1];
                        icon = QIcon(_i);
                    } else {
                        //print("HHH types" + types.toString());
                        resourceIcon(types.toString())
                    }
                    //print("icon:" + hasSymbol);
                } catch(e) {
                    var _i = resourceIcon(className);
                    print("fallback icon: " + _i + e);
                    icon = QIcon(_i);
                    print("icon2:" + _i);
                }
            }
        }

        Text {
            id: previewLabel
            text: label
            //text: url
            font.pixelSize: 14
            font.bold: true
            wrapMode: Text.Wrap
            color: theme.textColor
            anchors.top: itemFrame.top
            //anchors.bottom: infoLabel.top;
            anchors.left: previewImage.right
            anchors.right: itemFrame.right
            anchors.margins: 8
        }

        Text {
            id: infoLabel
            //image: metadataSource.data[DataEngineSource]["fileName"]
            //text: "the long and winding road..."
            text: className
            color: theme.textColor
            opacity: 0.8
            //font.pixelSize: font.pixelSize * 1.8
            font.pixelSize: 12
            height: 14
            width: parent.width - previewImage.width
            //wrapMode: Text.Wrap
            anchors.right: itemFrame.right
            anchors.top: previewLabel.bottom
            anchors.bottom: itemFrame.bottom
            anchors.left: previewImage.right
            anchors.margins: 8
            visible: infoLabelVisible
        }
    }
}
