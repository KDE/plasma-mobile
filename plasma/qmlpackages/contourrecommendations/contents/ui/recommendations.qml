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
import org.kde.qtextracomponents 0.1
import org.kde.plasma.graphicswidgets 0.1 as PlasmaWidgets
import org.kde.plasma.core 0.1 as PlasmaCore

Item {
    id: main
    width: 200
    height: 200
    state: "Passive"

    PlasmaCore.DataSource {
        id: recommendationsSource
        engine: "org.kde.recommendations"
        interval: 0
        connectedSources: sources
    }


    PlasmaCore.Theme {
        id: theme
    }

    ListView {
        anchors.fill: parent
        clip: true

        model: PlasmaCore.SortFilterModel {
            sourceModel: PlasmaCore.DataModel {
                dataSource: recommendationsSource
            }
            sortRole: "relevance"
            sortOrder: Qt.DescendingOrder
        }

        onCountChanged: {
            if (count > 0) {
                main.state = "Normal"
            } else {
                main.state = "Passive"
            }
        }
        delegate: RecommendationDelegate {
                name: model.name
                description: model.description
                icon: model.icon
                // actions: model.actions
            }
    }
}
