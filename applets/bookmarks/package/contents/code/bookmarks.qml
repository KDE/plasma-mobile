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
        /*
        onSourceAdded: {
            connectSource(source)
        }
        onDataUpdated: {
            console.log("=+++++++ DATA UPDATED");
        }
        Component.onCompleted: {
            console.log("sources connected:" + connectedSources);
            //connectedSources = sources
        }
        */
    }
    /*
    Image {
        width: 320
        height: 320
        //source: "/tmp/bla.png"
        anchors.fill: itemFrame
    }
    */
    ListView {
        anchors.fill: parent
        snapMode: ListView.SnapToItem
        clip: true
        highlightMoveDuration: 300

        model: PlasmaCore.DataModel {
            dataSource: previewSource
        }
        spacing: 8;
        //Rectangle {
        //    anchors.fill: parent
        //    color: red
            //opacity: 0.5
        //}
        delegate: Item {
            id: bookmarkItem
            height: 120
            //clip: true
            //property string filename: previewSource.data[DataEngineSource]["fileName"]
            //property string filename: "/tmp/sebas-kde4/kde-sebas/plasma_engine_previewengineT20455.png"
            //PlasmaWidgets.Frame {
            //    anchors.fill: parent
            //}

            PlasmaWidgets.Frame {
                id: itemFrame
                anchors.fill: parent;
                frameShadow: "Raised"
                

                Image {
                    id: previewImage
                    //image: previewSource.data[DataEngineSource]["fileName"]
                    source: fileName
                    //image: "/tmp/sebas-kde4/kde-sebas/plasma_engine_previewenginef21610.png"
                    //source: "/tmp/bla.png"
                    height:120
                    width: 180
                    //anchors.fill: itemFrame;
                    //anchors.left: itemFrame.left
                    //anchors.bottom: itemFrame.bottom
                    //anchors.top: itemFrame.top

                }
                PlasmaWidgets.Label {
                    //image: previewSource.data[DataEngineSource]["fileName"]
                    text: {
                        var s = DataEngineSource;
                        s = s.replace("http://", "");
                        s = s.replace("www.", "");
                        console.log(s + s.length);

                        return s;
                    }
                    font.pixelSize: font.pixelSize * 2.2

                    //image: "/tmp/bla.png"
                    //text: previewSource.connectedSources[0]
                    //source: "/tmp/bla.png"
                    //height:100
                    width: 400
                    id: previewLabel
                    anchors.top: itemFrame.top
                    //anchors.bottom: infoLabel.top;
                    anchors.left: previewImage.right
                    anchors.right: itemFrame.right

                }
                PlasmaWidgets.Label {
                    //image: previewSource.data[DataEngineSource]["fileName"]
                    text: "To specify that an image should be loaded by an image provider, use the \"image:\" scheme for the URL source of the image, followed by the identifiers of the image provider and the requested image. For example:"
                    opacity: 0.6
                    //font.pixelSize: font.pixelSize * 1.8

                    //image: "/tmp/bla.png"
                    //text: previewSource.connectedSources[0]
                    //source: "/tmp/bla.png"
                    //height:100
                    height: 80
                    width: 400
                    id: infoLabel
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
