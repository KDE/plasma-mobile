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

    /*
    Component.onCompleted: {
        //plasmoid.addEventListener("dataUpdated", dataUpdated)
        //dataEngine("favorites").connectSource("http://www.engadget.com", page, 500)
    }

    function dataUpdated(source, data)
    {
        console.log("data updated:" + source);
        //console.log(i18n("Time (fetched without datasource) Is %1 in %2", data.Time.toString(), source))
    }
    */

    PlasmaCore.DataSource {
        id: previewSource
        engine: "preview"

        connectedSources: [ "file:///home/sebas/Documents/Curacao/wallpaper.jpg",
            "http://www.volkskrant.nl",
            //"http://www.google.com"
            //"http://www.kde.org",
            ///"http://www.engadget.com",
            "http://www.tweakers.net"
        ]
        interval: 0
        //connectedSources: sources
        onSourceAdded: {
            console.log("source added:" + source);
            connectSource(source);
        }

        onDataChanged: {
            console.log("========================== Data changed");
            for (d in data) {
                print("  data " + d);
            }
        }
        Component.onCompleted: {
            connectedSources = sources
        }

    }
    /*
    Component.onCompleted: {
        console.log("completed");
        //connectSource(connectedSources[0]);
    }
    */
    PlasmaCore.Theme {
        id: theme
    }

    Text {
        id: header
        text: i18n("<h2>My Favorites</h2>")
        anchors { top: parent.top; left:parent.left; right: parent.right }
    }

    ListView {
        id: webItemList
        //anchors.fill: parent
        height: 400
        snapMode: ListView.SnapToItem
        clip: true
        highlightMoveDuration: 300
        spacing: 8;
        anchors { top: header.bottom; left:parent.left; right: parent.right }

        model: PlasmaCore.DataModel {
            dataSource: previewSource
        }

        delegate: Item {
            id: bookmarkItem
            height: 128
            width: 300

            PlasmaWidgets.Frame {
                id: itemFrame
                anchors.fill: bookmarkItem;
                frameShadow: "Raised"

                Image {
                    id: previewImage
                    //anchors.fill: item
                    //source: model.data[DataEngineSource]["fileName"]
                    //source: fileName
                    source: "/tmp/thumbnail.png"
                    height:96
                    width: 128

                }

                PlasmaWidgets.Label {
                    /*
                    text: {
                        //var s = url;
                        var s = "http://plasma.kde.org";
                        s = s.replace("http://", "");
                        s = s.replace("https://", "");
                        s = s.replace("www.", "");
                        console.log(s + s.length);
                        return s;
                    }
                    */
                    text: "this is the url"
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
                /*
                Component.onCompleted: {
                    //return;
                    //console.log(" =========== Item ========= " + DataEngineSource )
                    print("Print works.");
                    for (var i in data) {
                        print(i + " -> " + data[i])
                    }
                    var s;
                    for (s in previewSource.data) {
                        console.log("_____ " + s);
                        //console.log("-->:" + s + "length: " + previewSource.data[s]["http://www.kde.org"]["fileName"]);
                        for (k in previewSource.data[s]) {
                            var v = previewSource.data[s][k];
                            console.log("       v:" + k + " :: " + v);
                            //if (k.indexOf("") != -1) {
                            //    console.log(s+ "       =====> v:" + k + previewSource.data[s][k]);
                            //}
                        }
                    }
                }
                */
            }

            Component.onCompleted: {
                //return;
                //console.log(" =========== Item ========= " + DataEngineSource )
                //print("bookmarkItem-----" + bookmarkItem.DataEngineSource);
                for (var i in previewSource) {
                    print(" pewviewSource elements:" + i)
                }
                print("this ===========");
                for (var i in this) {
                    print(" elements:" + i)
                }
                for (var i in data) {
                    print(i + " -> " + data[i])
                }
                var s;
                for (s in previewSource.data) {
                    console.log("_____ " + s);
                    //console.log("-->:" + s + "length: " + previewSource.data[s]["http://www.kde.org"]["fileName"]);
                    for (k in previewSource.data[s]) {
                        var v = previewSource.data[s][k];
                        console.log("       v:" + k + " :: " + v);
                        //if (k.indexOf("") != -1) {
                        //    console.log(s+ "       =====> v:" + k + previewSource.data[s][k]);
                        //}
                    }
                }
            }
        }
    }

    Text {
        text: "end."
        anchors { left:parent.left; right: parent.right; bottom: parent.bottom; }

    }
}
