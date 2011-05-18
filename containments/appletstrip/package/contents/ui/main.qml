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
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import Qt 4.7
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.qtextracomponents 0.1 as QtExtra

import "LayoutManager.js" as LayoutManager

Item {
    id: main
    signal shrinkRequested
    width: 1024
    height: 600

    property int actionSize: 48
    property int appletColumns: 3
    property string appletsOrder

    Component.onCompleted: {

        plasmoid.containmentType = "CustomContainment"
        plasmoid.movableApplets = false

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
        var component = Qt.createComponent("PlasmoidContainer.qml");
        var plasmoidContainer = component.createObject(appletsRow, {"x": pos.x, "y": pos.y});
        var index = appletsRow.children.length
        if (pos.x >= 0) {
            index = pos.x/(main.width/appletColumns)
        }
        plasmoidContainer.applet = applet
        appletsRow.insertAt(plasmoidContainer, index)
    }

    Item {
        id: spacer
        width: main.width/appletColumns
        height: 1
    }

    PlasmaCore.Theme {
        id: theme
    }

    PlasmaCore.Svg {
        id: iconsSvg
        imagePath: "widgets/action-overlays"
    }

    PlasmaCore.Svg {
        id: configIconsSvg
        imagePath: "widgets/configuration-icons"
    }
    

    Item {
        id: appletsFlickableParent
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        //FIXME: assumes a rectangular region
        property variant availScreenRect: plasmoid.availableScreenRegion(plasmoid.screen)[0]


        anchors.leftMargin: availScreenRect.x
        anchors.topMargin: availScreenRect.y
        anchors.rightMargin: parent.width - availScreenRect.width - availScreenRect.x
        anchors.bottomMargin: parent.height - availScreenRect.height - availScreenRect.y

        Flickable {
            id: appletsFlickable
            anchors.top: appletsFlickableParent.top
            anchors.bottom: appletsFlickableParent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            clip: true
            interactive:true
            contentWidth: mainRow.width
            contentHeight: height

            width: Math.min(parent.width, mainRow.width)

            Row {
                id: mainRow

                Row {
                    id: appletsRow
                    height: appletsFlickable.height
                    add: Transition {
                        NumberAnimation {
                            properties: "x"
                            easing.type: Easing.OutCubic
                            duration: 250
                        }
                    }
                    move: Transition {
                        NumberAnimation {
                            properties: "x"
                            easing.type: Easing.OutCubic
                            duration: 250
                        }
                    }

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
                }
                Item {
                    height: appletsFlickable.height
                    width: main.width/appletColumns
                    Column {
                        anchors.centerIn: parent
                        ActionButton {
                            elementId: "add-normal"
                            action: plasmoid.action("add widgets")
                        }
                        ActionButton {
                            svg: configIconsSvg
                            elementId: "configure"
                            action: plasmoid.action("configure")
                            //FIXME: WHY?
                            Component.onCompleted: {
                                action.enabled = true
                            }
                        }
                    }
                }
            }
        }
    }
}
