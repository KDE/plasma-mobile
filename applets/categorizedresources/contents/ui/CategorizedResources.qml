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

import QtQuick 1.0
import org.kde.plasma.graphicswidgets 0.1 as PlasmaWidgets
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents

Item {
    id: main
    width: 540
    height: 540

    property alias urls: metadataSource.connectedSources

    PlasmaCore.DataSource {
        id: metadataSource
        engine: "org.kde.active.metadata"
        interval: 0

        onSourceAdded: {
            //console.log("source added:" + source);
            connectSource(source);
        }

        onDataChanged: {
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

    Item {
        property variant availScreenRect: plasmoid.availableScreenRegion(plasmoid.screen)[0]


        anchors.fill: parent
        anchors.leftMargin: availScreenRect.x
        anchors.topMargin: availScreenRect.y
        anchors.rightMargin: parent.width - availScreenRect.width - availScreenRect.x
        anchors.bottomMargin: parent.height - availScreenRect.height - availScreenRect.y

        Rectangle {
            x: 32
            y: 48
            height: childrenRect.height
            width: childrenRect.width + 20
            color: Qt.rgba(1,1,1,0.8)
            radius: 10
            anchors.top: searchRow.top
            anchors.left: parent.left
            anchors.leftMargin: 22

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: plasmoid.activityName
                font.pixelSize: 25
            }
        }

        Row {
            id: searchRow
            anchors {
                top: parent.top
                right: parent.right
                topMargin: 12
                rightMargin: 22
            }

            PlasmaWidgets.LineEdit {
                id: searchBox
                clearButtonShown: true
                width: 200
                onTextChanged: {
                    timer.running = true
                }
            }
            PlasmaWidgets.IconWidget {
                id: icon
                icon: QIcon("system-search")
                size: "32x32"
                onClicked: {
                    timer.running = true
                    print(categoryListModel.categories)
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
            categoryRole: "className"
        }

        Flow {
            id: resultsFlow
            spacing: 8
            flow: Flow.TopToBottom

            anchors {
                top: searchRow.bottom
                left:parent.left
                bottom: parent.bottom
                right: parent.right
                leftMargin: 32
                rightMargin: 32
            }

            Repeater {
                model: categoryListModel.categories

                ItemGroup {
                    
                }
            }
        }
    }

    Timer {
       id: timer
       running: false
       repeat: false
       interval: 1000
       onTriggered: {
            plasmoid.busy = true
            metadataSource.connectedSources = [searchBox.text]
       }
    }

    ContextMenu {
        id: contextMenu
    }
}
