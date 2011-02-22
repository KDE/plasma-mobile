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

Item {
    id: main
    signal shrinkRequested
    state: height>48?"active":"passive"

    Component.onCompleted: {
        plasmoid.appletAdded.connect(addApplet)

        for (var i = 0; i<plasmoid.applets.length; ++i) {
            addApplet(plasmoid.applets[i], 0);
        }
    }


    function addApplet(applet, pos)
    {
        var component = Qt.createComponent("PlasmoidContainer.qml");
        var plasmoidContainer = component.createObject(tasksRow, {"x": pos.x, "y": pos.y});
        plasmoidContainer.plasmoid = applet
        applet.parent = plasmoidContainer
        applet.x=0
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

    PlasmaCore.DataSource {
        id: timeEngine
        engine: "time"
        interval: 30000
        connectedSources: ["Local"]
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
            anchors.horizontalCenter: parent.horizontalCenter
            clip: true
            interactive:true
            contentWidth: tasksRow.width
            contentHeight: tasksRow.height

            width: Math.min(parent.width, tasksRow.width)

            Row {
                id: tasksRow

                height: tasksFlickable.height

                Repeater {
                    id: tasksRepeater
                    model:  PlasmaCore.DataModel {
                        dataSource: statusNotifierSource
                    }
                    delegate: TaskWidget {
                        
                    }
                }
            }
        }
    }
}
