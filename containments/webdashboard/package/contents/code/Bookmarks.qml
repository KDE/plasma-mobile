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

import QtQuick 1.0
import org.kde.plasma.graphicswidgets 0.1 as PlasmaWidgets
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.graphicslayouts 4.7 as GraphicsLayouts
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents

Item {
    id: bookmarks
    width: 300
    height: 144

    //property alias title: header
    property alias urls: metadataSource.connectedSources

    PlasmaCore.DataSource {
        id: metadataSource
        engine: "org.kde.active.bookmarks"
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
                //statusLabel.text = "";
                plasmoid.busy = false
            }
        }
        Component.onCompleted: {
            //connectedSources = sources;
            connectedSources = [ "all" ]
        }

    }

    PlasmaCore.Theme {
        id: theme
    }

    ListView {
        id: webItemList
        //anchors.fill: parent
        //height: 600
        height: 96 + (spacing * 2)
        snapMode: ListView.SnapToItem
        clip: true
        highlightMoveDuration: 300
        spacing: 16;
        orientation: Qt.Horizontal
        anchors.fill: parent

        model: PlasmaCore.DataModel {
            dataSource: metadataSource
            keyRoleFilter: ".*"
        }

        delegate: MobileComponents.ResourceDelegate {
            width:240
            height: 96
            resourceType: model.resourceType
        }
    }
}
