/*
 *  Copyright 2014 Antonis Tsiapaliokas <antonis.tsiapaliokas@kde.org>
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
import org.kde.plasma.private.mobileshell 0.2 as MobileShell

Item {
    id: root

    PlasmaCore.DataModel {
        id: applicationData
        dataSource: PlasmaCore.DataSource {
            engine: "apps"
            connectedSources: sources
        }
    }

    PlasmaCore.SortFilterModel {
        id: filterModel
        sourceModel: applicationData
        sortRole: "ApplicationNameRole"
        filterRegExp: searchApplicationField.text
    }

    Column {
        id: col
        spacing: units.largeSpacing
        anchors {
            fill: parent
            left: parent.left
            right: parent.right
            top: parent.top
        }

        PlasmaComponents.TextField{
            id: searchApplicationField
            width: parent.width / 12
            anchors.horizontalCenter: parent.horizontalCenter
        }

        MobileShell.IconGrid {
            id: applicationsList
            property int currentIndex: 0
            onCurrentIndexChanged: {
                currentPage = Math.max(0, Math.floor(currentIndex/pageSize))
            }

            height: parent.height - searchApplicationField.height
            width: parent.width
            delegateWidth: Math.floor(applicationsList.width / Math.max(Math.floor(applicationsList.width / (units.gridUnit*12)), 3))
            delegateHeight: delegateWidth / 1.6

            model: filterModel
            delegate: MouseArea {
                width: applicationsList.delegateWidth
                height: applicationsList.delegateHeight

                PlasmaCore.IconItem {
                    id: applicationIcon
                    source: model.iconName
                    width: parent.width / 1.6
                    height: parent.height / 1.6
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                }

                PlasmaComponents.Label {
                    anchors.bottom: parent.bottom
                    text: model.name
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: applicationIcon.bottom
                }
                onClicked: {
                    applicationsList.currentIndex = (applicationsList.currentPage * applicationsList.pageSize) + index
                    applicationData.runApplication(model.menuId)
                }
            }
        }
    }
}
