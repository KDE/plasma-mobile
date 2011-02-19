/*
 *   Copyright 2010 Alexis Menard <menard@kde.org>
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
    state: height>48?"active":"passive"
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
        anchors.right: clockText.left
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
    function formatTime( dateString)
    {
        var date = new Date(dateString)
        return date.getHours()+":"+date.getMinutes()
    }
    Text {
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        id: clockText
        text: formatTime("January 1, 1971 "+timeEngine.data["Local"]["Time"])
        font.pixelSize: height
        color: theme.textColor
    }
}
