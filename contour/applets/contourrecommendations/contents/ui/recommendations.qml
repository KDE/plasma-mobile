/*
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
import org.kde.qtextracomponents 4.7
import org.kde.plasma.graphicswidgets 0.1 as PlasmaWidgets
import org.kde.plasma.core 0.1 as PlasmaCore

Item {
    width: 200
    height: 200

    Component.onCompleted: {
        plasmoid.drawWallpaper = false
        plasmoid.containmentType = "CustomContainment"
    }

    PlasmaCore.DataSource {
        id: activitySource
        engine: "org.kde.activities"
        onSourceAdded: {
            if (source != "Status") {
                connectSource(source)
            }
        }
        Component.onCompleted: {
            connectedSources = sources
        }
    }

    RecommendationsModel {
       id: recommendationsModels
    }

    PlasmaCore.Theme {
        id: theme
    }

    ListView {
        anchors.fill: parent

        model: recommendationsModels.model(activitySource.data[activitySource.data["Status"]["Current"]]["Name"])

        delegate: RecommendationDelegate {
                text: model.text
                description: model.description
                icon: model.icon
                command: model.command
            }
    }
}
