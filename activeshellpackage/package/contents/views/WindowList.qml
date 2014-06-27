/*
 *  Copyright 2014 Marco Martin <mart@kde.org>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  2.010-1301, USA.
 */

import QtQuick 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

Item {
    id: root

    PlasmaCore.DataSource {
        id: tasksSource
        dataEngine: "tasks"
        interval: 0
        connectedSources: ["tasks"]
    }

    function performOperation(id, what) {
        var service = tasksSource.serviceForSource("tasks");
        var operation = service.operationDescription(what);
        operation["Id"] = id
        return service.startOperationCall(operation);
    }

    ListView {
        id: tasksList
        anchors.fill: parent

        orientation: ListView.Horizontal
        spacing: units.largeSpacing

        model: tasksSource.models["tasks"]

        delegate: MouseArea {
            width: height * 1.6
            height: parent.height

            Rectangle {
                anchors.fill: parent
                color: theme.backgroundColor
            }
            PlasmaCore.WindowThumbnail {
                anchors.fill: parent
                winId: model["WindowList"][0]
            }

            Rectangle {
                anchors {
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }
                height: taskName.height
                color: theme.backgroundColor
                opacity: 0.6
            }
            PlasmaComponents.Label {
                id: taskName
                anchors.bottom: parent.bottom
                text: model.DisplayRole
            }
            PlasmaComponents.ToolButton {
                iconSource: "window-close"
                flat: false
                anchors {
                    right: parent.right
                    top: parent.top
                    margins: units.smallSpacing
                }
                width: units.iconSizes.medium
                height: width
                onClicked: performOperation(model["Id"], "close");
            }
            onClicked: {
                performOperation(model["Id"], "activate");
            }
        }
    }
}