/*
 *   Copyright 2011 Marco Martin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
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
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.qtextracomponents 0.1 as QtExtra

import "plasmapackage:/code/LayoutManager.js" as LayoutManager

Item {
    id: main
    signal shrinkRequested
    state: height>48?"active":"passive"

    Component.onCompleted: {
        plasmoid.drawWallpaper = false
        plasmoid.containmentType = "CustomContainment"
        plasmoid.movableApplets = false

        plasmoid.appletAdded.connect(addApplet)

        appletsOrder = plasmoid.readConfig("AppletsOrder")

        //array with all the applet ids, in order
        var appletIds = Array()
        if (appletsOrder.length > 0) {
            appletIds = appletsOrder.split(":")
        }

        //all applets loaded, indicized by id
        var appletsForId = new Array()

        //fill appletsForId
        for (var i = 0; i < plasmoid.applets.length; ++i) {
            var applet = plasmoid.applets[i]
            appletsForId[applet.id] = applet
        }

        //add applets present in AppletsOrder
        for (var i = 0; i < appletIds.length; ++i) {
            var id = appletIds[i]
            var applet = appletsForId[id]
            if (applet) {
                addApplet(applet, Qt.point(-1,-1));
                //discard it, so will be easy to find out who wasn't in the series
                appletsForId[id] = null
            }
        }

        for (var id in appletsForId) {
            var applet = appletsForId[id]
            if (applet) {
                addApplet(applet, Qt.point(-1,-1));
            }
        }

        plasmoid.appletAdded.connect(addApplet)
        LayoutManager.saveOrder()
    }


    function addApplet(applet, pos)
    {
        var component = Qt.createComponent("PlasmoidContainer.qml")

        if (applet.pluginName == "org.kde.sharelikeconnect") {
            var plasmoidContainer = component.createObject(rightPanel);
            plasmoidContainer.parent = rightPanel
            plasmoidContainer.anchors.top = rightPanel.top
            plasmoidContainer.anchors.bottom = rightPanel.bottom
            plasmoidContainer.applet = applet
            return

        } else if (applet.pluginName == "digital-clock") {
            var plasmoidContainer = component.createObject(rightPanel);
            plasmoidContainer.parent = centerPanel
            plasmoidContainer.anchors.top = centerPanel.top
            plasmoidContainer.anchors.bottom = centerPanel.bottom
            plasmoidContainer.applet = applet
            return
        }

        var plasmoidContainer = component.createObject(tasksRow, {"x": pos.x, "y": pos.y});

        var index = tasksRow.children.length
        if (pos.x >= 0) {
            //FIXME: this assumes items are square
            index = pos.x/main.height
        }
        tasksRow.insertAt(plasmoidContainer, index)
        plasmoidContainer.anchors.top = tasksRow.top
        plasmoidContainer.anchors.bottom = tasksRow.bottom
        plasmoidContainer.applet = applet

    }

    PlasmaCore.DataSource {
          id: statusNotifierSource
          engine: "statusnotifieritem"
          interval: 0
          onSourceAdded: {
             connectSource(source)
          }
          Component.onCompleted: {
              connectedSources = sources
          }
    }

    PlasmaCore.Theme {
        id: theme
    }

    Item {
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        Flickable {
            id: tasksFlickable
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            interactive:true
            contentWidth: tasksRow.width
            contentHeight: tasksRow.height

            width: Math.min(parent.width, tasksRow.width)

            Row {
                id: tasksRow
                spacing: 8
                height: tasksFlickable.height
                property string skipItems

                function insertAt(item, index)
                {
                    LayoutManager.insertAt(item, index)
                }

                function remove(item)
                {
                    LayoutManager.remove(item)
                }

                function saveOrder()
                {
                    LayoutManager.saveOrder()
                }

                Repeater {
                    id: tasksRepeater
                    model: PlasmaCore.SortFilterModel {
                        id: filteredStatusNotifiers
                        filterRole: "Title"
                        filterRegExp: tasksRow.skipItems
                        sourceModel: PlasmaCore.DataModel {
                            dataSource: statusNotifierSource
                        }
                    }

                    delegate: TaskWidget {
                    }
                }


                Component.onCompleted: {
                    items = plasmoid.readConfig("SkipItems")
                    if (items != "") {
                        skipItems = "^(?!" + items + ")"
                    } else {
                        skipItems = ""
                    }
                }
            }
        }
        Row {
            id: centerPanel
            anchors {
                top: parent.top
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
            }
        }
        Row {
            id: rightPanel
            anchors {
                top: parent.top
                bottom: parent.bottom
                right: parent.right
                rightMargin: 8
            }
        }
    }
}
