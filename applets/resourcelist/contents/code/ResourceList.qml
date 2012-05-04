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
 *   GNU Library General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import Qt 4.7
import org.kde.plasma.components 0.1 as PlasmaComponents
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents
import org.kde.metadatamodels 0.1 as MetadataModels

Item {
    id: bookmarks
    width: 300
    height: 150

    property alias title: header

    PlasmaCore.Theme {
        id: theme
    }

    PlasmaComponents.Label {
        id: header
        text: i18n("<h2>Search ...</h2>")
        anchors { top: parent.top; left:parent.left; right: parent.right; bottomMargin: 8 }
    }

    Row {
        id: searchRow
        width: parent.width
        anchors { top: header.bottom; }

        PlasmaComponents.TextField {
            id: searchBox
            clearButtonShown: true
            width: parent.width - parent.spacing
            onTextChanged: {
                timer.running = true
            }
        }

    }

    ListView {
        id: webItemList
        //anchors.fill: parent
        //height: 600
        snapMode: ListView.SnapToItem
        clip: true
        highlightMoveDuration: 300
        spacing: 8;
        orientation: Qt.Vertical
        anchors { top: searchRow.bottom; left:parent.left; right: parent.right; bottom: statusLabel.top }

        model: MetadataModels.MetadataModel {
            id: metadataModel
            onRunningChanged: {
                if (!running) {
                    statusLabel.text = "";
                    plasmoid.busy = false
                }
            }
        }

        delegate: MobileComponents.ResourceDelegate {
            width:400
            height:72
            //resourceType: model.resourceType
        }
    }
    PlasmaComponents.ScrollBar {
        flickableItem: webItemList
    }

    PlasmaComponents.Label {
        id: statusLabel
        text: i18n("Idle.")
        anchors { left:parent.left; right: parent.right; bottom: parent.bottom; }
    }

    Timer {
       id: timer
       running: false
       repeat: false
       interval: 2000
       onTriggered: {
            plasmoid.busy = true
            metadataModel.queryString = searchBox.text
            statusLabel.text = i18n("Searching for %1...", searchBox.text);
       }
    }
}
