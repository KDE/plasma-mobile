// -*- coding: iso-8859-1 -*-
/*
 *   Copyright 2011 Sebastian Kügler <sebas@kde.org>
 *   Copyright 2011 Marco Martin <mart@kde.org>
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
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents

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
            statusLabel.text = i18n("Idle.");
            plasmoid.busy = false
        }
        Component.onCompleted: {
            //connectedSources = sources;
            //connectedSources = [ "wall" ]
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
            icon: QIcon("system-search")
            onClicked: {
                timer.running = true
            }
        }

    }

    PlasmaCore.DataModel {
        id: metadataModel
        dataSource: metadataSource
    }

    MobileComponents.CategorizedProxyModel {
        id: categoryListModel
        sourceModel: metadataModel
        categoryRole: "resourceType"
    }

    Flow {
        id: resultsFlow

        anchors {
            top: searchRow.bottom
            left:parent.left
            bottom: statusLabel.top
            right: parent.right
        }

        Repeater {
            model: categoryListModel.categories.length
            ListView {
                id: webItemList
                height: 200
                width: 200
                snapMode: ListView.SnapToItem
                clip: true
                highlightMoveDuration: 300
                spacing: 8;
                orientation: Qt.Vertical

                model: MobileComponents.CategorizedProxyModel {
                    sourceModel: metadataModel
                    categoryRole: "resourceType"
                    currentCategory: categories[index]
                }

                delegate: MobileComponents.ResourceDelegate {
                    width:400
                    height:72
                    resourceType: model.resourceType
                }
            }
        }
    }

    Text {
        id: statusLabel
        text: i18n("Idle.")
        anchors { left:parent.left; right: parent.right; bottom: parent.bottom; }
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
