// -*- coding: iso-8859-1 -*-
/*
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
import org.kde.plasma.graphicslayouts 4.7 as GraphicsLayouts

Item {
    id: bookmarks
    width: 540
    height: 540

    PlasmaCore.DataSource {
        id: previewSource
        engine: "preview"
        connectedSources: [
            "http://www.volkskrant.nl",
            "http://www.google.com",
            "http://www.kde.org",
            "http://www.engadget.com",
            "http://www.tweakers.net"
        ]
        interval: 0
    }

    ListView {
        anchors.fill: parent
        snapMode: ListView.SnapToItem
        clip: true
        highlightMoveDuration: 300
        spacing: 8;

        model: PlasmaCore.DataModel {
            dataSource: previewSource
        }

        delegate: Item {
            id: bookmarkItem
            height: 24

            PlasmaWidgets.Frame {
                id: itemFrame
                anchors.fill: parent;
                frameShadow: "Raised"

                Image {
                    id: previewImage
                    //image: previewSource.data[DataEngineSource]["fileName"]
                    source: fileName
                    height:32
                    width: 42

                }

                PlasmaWidgets.Label {
                    text: {
                        var s = url;
                        s = s.replace("http://", "");
                        s = s.replace("www.", "");
                        console.log(s + s.length);

                        return s;
                    }
                    font.pixelSize: 14
                    font.bold: true

                    width: 400
                    id: previewLabel
                    anchors.top: itemFrame.top
                    //anchors.bottom: infoLabel.top;
                    anchors.left: previewImage.right
                    anchors.right: itemFrame.right

                }

                Text {
                    //image: previewSource.data[DataEngineSource]["fileName"]
                    text: "To specify that an image should be loaded by an image provider, use the \"image:\" scheme for the URL source of the image, followed by the identifiers of the image provider and the requested image. For example:"
                    opacity: 0.6
                    //font.pixelSize: font.pixelSize * 1.8
                    font.pixelSize: 11
                    height: 14
                    width: 200
                    id: infoLabel
                    wrapMode: Text.Wrap
                    anchors.right: itemFrame.right
                    anchors.top: previewLabel.bottom
                    anchors.bottom: itemFrame.bottom
                    anchors.left: previewImage.right

                }

                Component.onCompleted: {
                    return;
                    /*
                    console.log(" =========== Item ========= " + status )
                    var s;
                    for (s in previewSource.data) {
                        console.log(url);
                        console.log("-->:" + s + "length: " + previewSource.data[s]["http://www.kde.org"]["fileName"]);
                        for (k in previewSource.data.s) {
                            console.log("       v:" + k);
                            //if (k.indexOf("") != -1) {
                            //    console.log(s+ "       =====> v:" + k + previewSource.data[s][k]);
                            //}
                        }
                    }
                    */
                }
            }
        }
    }
}
