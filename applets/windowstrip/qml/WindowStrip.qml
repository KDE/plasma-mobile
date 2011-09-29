// -*- coding: iso-8859-1 -*-
/*
 *   Author: Marco Martin <mart@kde.org>
 *   Date: Sun Nov 7 2010, 18:51:24
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
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents
import org.kde.qtextracomponents 0.1

Item {
    id: main
    width: 500
    height: 150

    property int iconSize: 22


    PlasmaCore.DataSource {
        id: tasksSource
        engine: "tasks"
        interval: 0
        onSourceAdded: {
            //print("SOURCE added: " + source);
            connectSource(source)
        }
        Component.onCompleted: {
            connectedSources = sources
        }
        onDataChanged: {
            positionsTimer.restart()
        }
    }

    function windowProperties(item)
    {
        var itemPos = item.mapToItem(mainRow, 0, 0)
        var properties = new Object()

        properties.winId = item.winId
        //FIXME: why those hardoced numbers?
        properties.x = itemPos.x + 10
        properties.y = itemPos.y + 20
        properties.width = item.width - 20
        properties.height = item.height - 48

        return properties
    }

    Timer {
        id: positionsTimer
        interval: 300
        repeat: false
        onTriggered: {
            var childrenPositions = Array()

            childrenPositions[0] = windowProperties(homeScreenThumbnail)
            for (var i = 0; i < windowsRow.children.length; i++) {
                if (!windowsRow.children[i].visible) {
                    continue
                }
                childrenPositions[i+1] = windowProperties(windowsRow.children[i])
            }
            windowFlicker.childrenPositions = childrenPositions
        }
    }

    PlasmaCore.Theme {
        id: theme
    }

    PlasmaCore.Svg {
        id: iconsSvg
        imagePath: "widgets/configuration-icons"
    }

    // connect from C++ to update
    // - position of the windows, relative to window element
    // - actual position of the row
    // -> calculate screen coordinates from these

    Flickable {
        id: windowFlicker
        objectName: "windowFlicker"

        interactive: true
        contentWidth: mainRow.width
        anchors.fill: parent
        property variant childrenPositions

        onMovementEnded: NumberAnimation {
            target: windowFlicker
            properties: "contentX"
            to: {
                //align to the cell
                var width = windowFlicker.height * 1.6
                var cells = Math.round(windowFlicker.contentX/width)
                return ((cells-1) * 10) + (width * cells)
            }
            duration: 250
        }

        Row {
            id: mainRow
            spacing: 10
            WindowThumbnail {
                id: homeScreenThumbnail
                property variant model
                visible: false
            }
            Row {
                id: windowsRow
                objectName: "windowsRow"
                spacing: 10

                Repeater {

                    model: PlasmaCore.SortFilterModel {
                        sourceModel: PlasmaCore.DataModel {
                            dataSource: tasksSource
                        }
                        filterRole: "onCurrentActivity"
                        filterRegExp: "true"
                        onModelReset: positionsTimer.restart()
                    }

                    onChildrenChanged: {
                        print(" someone changed something");
                        for (var ch in children) {
                            print("Child:" + ch.x)
                        }
                    }

                    delegate: WindowThumbnail {
                        id: windowThumbnail
                        Component.onCompleted: {
                            if (className == shellName) {
                                homeScreenThumbnail.visible = true
                                homeScreenThumbnail.model = model
                                homeScreenThumbnail.winId = DataEngineSource
                                windowThumbnail.visible = false
                            }
                        }
                    }
                }
                //purely a spacer
                Item {
                    width: height*1.6 + 32
                    height: main.height
                }
            }
        }
    }
}

