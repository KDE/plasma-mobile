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
    width: parent.width
    height: 180

    property alias title: header
    property alias urls: previewSource.connectedSources

    PlasmaCore.DataSource {
        id: previewSource
        engine: "preview"

        connectedSources: [
            "http://www.wikipedia.org",
            "http://www.google.com",
            "http://www.kde.org",
            "http://community.open-slx.de",
            "http://www.tweakers.net",
            "http://dot.kde.org",
            "http://plasma.kde.org",
            "http://planetkde.org",
            "http://lwn.net"
        ]

        //connectedSources: [ "http://www.google.com/linux", "http://plasma.kde.org/" ]
        interval: 0
        //connectedSources: sources
        onSourceAdded: {
            //console.log("source added:" + source);
            connectSource(source);
        }

        onDataChanged: {
            return;
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

    PlasmaWidgets.Label {
        id: header
        text: i18n("<h2>My Favorites</h2>")
        anchors { top: parent.top; left:parent.left; right: parent.right; bottomMargin: 8 }
    }

    ListView {
        id: webItemList
        //anchors.fill: parent
        height: 128 + (spacing * 2)
        snapMode: ListView.SnapToItem
        clip: true
        highlightMoveDuration: 100
        spacing: 8;
        orientation: Qt.Horizontal
        anchors { top: header.bottom; left:parent.left; right: parent.right; bottom: parent.bottom }

        model: PlasmaCore.DataModel {
            dataSource: previewSource
        }

        delegate: Item {
            id: bookmarkItem
            height: 128
            width: 300

            Item {
                id: itemFrame
                anchors { bottom: parent.bottom; top: parent.top; left: parent.left; right: parent.right; margins: 24; }
                height: 128
                //height: bookmarkItem.height
                //frameShadow: "Raised"

                Image {
                    id: previewImage
                    source: fileName
                    height:96
                    width: 128
                    anchors.margins: 8

                }

                PlasmaWidgets.Label {
                    id: previewLabel
                    text: {
                        var s = url;
                        s = s.replace("http://", "");
                        s = s.replace("https://", "");
                        s = s.replace("www.", "");
                        //console.log(s + s.length);
                        return s;
                    }
                    font.pixelSize: 14
                    font.bold: true
                    height: 14 * 2.4

                    width:250
                    anchors.top: itemFrame.top
                    //anchors.bottom: infoLabel.top;
                    anchors.left: previewImage.right
                    anchors.right: itemFrame.right
                    anchors.margins: 8

                }

                PlasmaWidgets.Label {
                    text: { url + " / " + status; }
                    opacity: 0.8
                    font.pixelSize: 14 * 0.8
                    height: 14
                    width: 200
                    id: infoLabel
                    //wrapMode: Text.Wrap
                    anchors.right: itemFrame.right
                    anchors.top: previewLabel.bottom
                    anchors.bottom: itemFrame.bottom
                    anchors.left: previewImage.right
                    anchors.margins: 8

                }
            }
        }
    }
}
