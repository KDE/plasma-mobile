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

    property alias title: header
    property alias urls: metadataSource.connectedSources

    PlasmaCore.DataSource {
        id: metadataSource
        engine: "metadata"
        interval: 0

        onSourceAdded: {
            //console.log("source added:" + source);
            connectSource(source);
        }

        onDataChanged: {
            for (d in data) {
                //print("  data " + d);
                //timer.running = false
                //statusLabel.text = i18n("Searching for %1 finished.", searchBox.text);
                statusLabel.text = "";
                plasmoid.busy = false
            }
        }
        Component.onCompleted: {
            connectedSources = sources;
        }

    }

    PlasmaCore.Theme {
        id: theme
    }

    PlasmaWidgets.Label {
        id: header
        text: i18n("<h2>Search ...</h2>")
        anchors { top: parent.top; left:parent.left; right: parent.right; bottomMargin: 8 }
    }

    Row {
        id: searchRow
        width: parent.width
        anchors { top: header.bottom; }

        PlasmaWidgets.LineEdit {
            id: searchBox
            clearButtonShown: true
            width: parent.width - icon.width - parent.spacing
            onTextChanged: {
                timer.running = true
            }
        }
        PlasmaWidgets.IconWidget {
            id: icon
            onClicked: {
                timer.running = true
            }
        Component.onCompleted: {
            icon.setIcon("system-search")
        }

        }

    }

    ListView {
        id: webItemList
        //anchors.fill: parent
        height: 600
        snapMode: ListView.SnapToItem
        clip: true
        highlightMoveDuration: 300
        spacing: 8;
        orientation: Qt.Vertical
        anchors { top: searchRow.bottom; left:parent.left; right: parent.right }

        model: PlasmaCore.DataModel {
            dataSource: metadataSource
        }

        delegate: Item {
            id: resourceItem
            height: 72
            width: parent.width

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
                //frameShadow: "Raised"

                PlasmaWidgets.IconWidget {
                    id: previewImage
                    //anchors.fill: item
                    //source: model.data[DataEngineSource]["fileName"]
                    //source: fileName
                    //source: fileName
                    //source: "/home/sebas/Documents/wallpaper.png"
                    height:64
                    width: 64
                    anchors.margins: 8
                    Component.onCompleted: {
                        print("Setting icon " + "nepomuk");
                        setIcon(hasSymbol);
                    }
                }

                PlasmaWidgets.Label {
                    id: previewLabel
                    text: label
                    //text: url
                    font.pixelSize: 14
                    font.bold: true
                    height: 30

                    width: parent.width - previewImage.width
                    anchors.top: itemFrame.top
                    //anchors.bottom: infoLabel.top;
                    anchors.left: previewImage.right
                    anchors.right: itemFrame.right
                    anchors.margins: 8

                }

                PlasmaWidgets.Label {
                    id: infoLabel
                    //image: metadataSource.data[DataEngineSource]["fileName"]
                    //text: "the long and winding road..."
                    text: { 
                        if (lastModified) {
                            lastModified.toString()
                        } else {
                            className
                        }
                    }
                    opacity: 0.6
                    //font.pixelSize: font.pixelSize * 1.8
                    font.pixelSize: 11
                    height: 14
                    width: parent.width - previewImage.width
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

    Text {
        id: statusLabel
        text: i18n("Idle.")
        anchors { top: webItemList.bottom; left:parent.left; right: parent.right; bottom: parent.bottom; }
    }

    Timer {
       id: timer
       running: false
       repeat: false
       interval: 1000
       onTriggered: {
            plasmoid.busy = true
            metadataSource.connectedSources = [searchBox.text]
            statusLabel.text = i18n("Searching for %1...", searchBox.text);
       }
    }
}
