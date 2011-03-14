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

Item {
    id: main

    Component.onCompleted: {
        plasmoid.drawWallpaper = false

        plasmoid.containmentType = "CustomContainment"
    }


    PlasmaCore.DataSource {
        id: activitySource
        engine: "org.kde.activities"
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

    ListView {
        anchors.fill: parent
        anchors.leftMargin: background.margins.left
        anchors.topMargin: background.margins.top
        anchors.rightMargin: background.margins.right
        anchors.bottomMargin: background.margins.bottom
        clip: true
        
        model: PlasmaCore.DataModel{
            dataSource: activitySource
        }
        
        delegate: Text {
            color: theme.textColor
            text: model["DataEngineSource"]=="Status"?i18n("New"):model["Name"]
            font.pixelSize: 24
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    var activityId = model["DataEngineSource"]
                    print(activityId)
                    var service = activitySource.serviceForSource(activityId)
                    var operation = service.operationDescription("setCurrent")
                    service.startOperationCall(operation)
                }
            }
        }
    }
}

