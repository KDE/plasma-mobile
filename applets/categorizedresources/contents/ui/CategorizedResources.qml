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
import org.kde.plasma.slccomponents 0.1 as SlcComponents

import "plasmapackage:/code/LayoutManager.js" as LayoutManager

Item {
    id: main
    width: 540
    height: 540

    property bool browsingActivity: searchBox.text.length == 0

    property alias urls: metadataSource.connectedSources

    Component.onCompleted: {
        LayoutManager.restore()
    }

    PlasmaCore.DataSource {
        id: metadataSource
        engine: "org.kde.active.metadata"
        interval: 0

        onSourceAdded: {
            //console.log("source added:" + source);
            //connectSource(source);
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


        Text {
            anchors.top: searchRow.top
            anchors.left: parent.left
            anchors.leftMargin: 22
            text: plasmoid.activityName
            font.bold: true
            style: Text.Outline
            styleColor: Qt.rgba(1, 1, 1, 0.6)
            font.pixelSize: 25
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
                }
            }

        }

        PlasmaCore.DataModel {
            id: metadataModel
            keyRoleFilter: ".*"
            dataSource: metadataSource
        }

        MobileComponents.CategorizedProxyModel {
            id: categoryListModel
            sourceModel: metadataModel
            categoryRole: "className"
        }

        //FIXME: debug purposes only, remove asap
        Flow {
            id: debugFlow
            anchors.fill: resultsFlow
            visible: false
            Repeater {
                model: 60
                Rectangle {
                    width: LayoutManager.cellSize.width
                    height: LayoutManager.cellSize.height
                }
            }
            function refresh()
            {
                for (var i=0; i<debugFlow.children.length; ++i) {
                    child = debugFlow.children[i]
                    child.opacity = LayoutManager.availableSpace(child.x,child.y, LayoutManager.cellSize.width, LayoutManager.cellSize.height).width>0?0.8:0.3
                }
            }
        }

        Item {
            id: resultsFlow
            //height: Math.min(300, childrenRect.height)
            width: Math.round((parent.width-64)/LayoutManager.cellSize.width)*LayoutManager.cellSize.width

            anchors {
                top: searchRow.bottom
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
            }


            Repeater {
                model: categoryListModel.categories

                ItemGroup {
                    id: group
                    
                }
            }
            Timer {
                id: layoutTimer
                repeat: false
                running: false
                interval: 2000
                onTriggered: {
                    for (var i=0; i<resultsFlow.children.length; ++i) {
                        child = resultsFlow.children[i]
                        if (LayoutManager.itemsConfig[child.name]) {
                            var rect = LayoutManager.itemsConfig[child.name]
                            child.x = rect.x
                            child.y = rect.y
                            child.width = rect.width
                            child.height = rect.height
                        } else {
                            child.x = 0
                            child.y = 0
                        }

                        child.visible = true
                        LayoutManager.positionItem(child)
                        child.enabled = true
                        debugFlow.refresh();
                    }
                }
            }
            Component.onCompleted: {
                LayoutManager.resultsFlow = resultsFlow
            }
        }
    }

    Timer {
       id: timer
       running: true
       repeat: false
       interval: 1000
       onTriggered: {
            LayoutManager.resetPositions()
            if (searchBox.text) {
                plasmoid.busy = true
                metadataSource.connectedSources = [searchBox.text]
            } else {
                plasmoid.busy = false
                metadataSource.connectedSources = ["CurrentActivityResources:"+plasmoid.activityId]
            }
       }
    }

    SlcComponents.SlcMenu {
        id: contextMenu
    }
}
