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
 *   GNU Library General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 2.0
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.mobilecomponents 0.2 as MobileComponents

MobileComponents.IconGrid {
    id: resultsGrid
    anchors.fill: parent
    property string resourceType: ""
    signal closeRequested()
    onCloseRequested: main.closed()
    delegateWidth: Math.floor(resultsGrid.width / Math.max(Math.floor(resultsGrid.width / (units.gridUnit*12)), 3))
    delegateHeight: delegateWidth / 1.6

    delegate: Item {
        width: resultsGrid.delegateWidth
        height: resultsGrid.delegateHeight
        PlasmaCore.FrameSvgItem {
                id: highlightFrame
                imagePath: "widgets/viewitem"
                prefix: "selected+hover"
                opacity: 0
                width: resultsGrid.delegateWidth
                height: resultsGrid.delegateHeight
                Behavior on opacity {
                    NumberAnimation {duration: 250}
                }
        }
        MobileComponents.ResourceDelegate {
            id: resourceDelegate
            resourceType: resultsGrid.resourceType
            width: parent.width
            height: parent.height

            onClicked: {
                activityResources.shownAgents = resultsGrid.resourceType;
                activityResources.linkResourceToActivity(url, function () {});
                activityResources.shownAgents = ":any"
                resultsGrid.closeRequested()
            }
        }
    }
}
