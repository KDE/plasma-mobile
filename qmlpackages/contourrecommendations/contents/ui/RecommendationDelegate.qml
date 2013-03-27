/*
 *   Copyright 2010 Marco Martin <notmart@gmail.com>
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
import QtQuick 1.0
import org.kde.plasma.components 0.1 as PlasmaComponents
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.qtextracomponents 0.1

PlasmaComponents.ListItem {
    id: listItem
    property string name
    property string description
    property string icon
    // property variant actions
    enabled: true
    onClicked: {
        var service = recommendationsSource.serviceForSource(DataEngineSource)
        var operation = service.operationDescription("executeAction")
        operation.Action = "" //actions[0].actionId

        service.startOperationCall(operation)
    }


    QIconItem {
        id: iconItem
        x: y
        anchors.verticalCenter: parent.verticalCenter
        width: theme.largeIconSize
        height: theme.largeIconSize
        icon: QIcon(listItem.icon)
    }

    Column {
        id: labelColumn
        anchors {
            left: iconItem.right
            //FIXME: why this can't be binded to another property?
            leftMargin: 10
            right: parent.right
            verticalCenter: parent.verticalCenter
        }

        PlasmaComponents.Label {
            text: listItem.name
            elide: Text.ElideRight
            anchors {
                left: parent.left
                right: parent.right
            }
        }
        PlasmaComponents.Label {
            font.pointSize: theme.smallestFont.pointSize
            text: listItem.description
            visible: listItem.description.length>0
            anchors {
                left: parent.left
                right: parent.right
            }
        }

    }
}
