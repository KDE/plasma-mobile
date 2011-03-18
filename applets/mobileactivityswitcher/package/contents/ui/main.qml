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
            if (source != "Status") {
                connectSource(source)
            }
        }
        Component.onCompleted: {
            connectedSources = sources.filter(function(val) {
                return val != "Status";
            })
        }
    }

    PlasmaCore.Theme {
        id: theme
    }

    ListView {
        id: activityList
        anchors.fill: parent
        clip: true
        highlightFollowsCurrentItem: false
        spacing: 8

        
        model: PlasmaCore.DataModel{
            dataSource: activitySource
        }
        
        //FIXME: why a timer is needed?
        Timer {
            id: highlightTimer
            interval: 250;
            running: false;
            property int pendingIndex: -1
            onTriggered:  {
                activityList.currentIndex = pendingIndex
            }
        }
        
        delegate: Text {
            id: delegate
            color: theme.textColor
            text: model["DataEngineSource"]=="Status"?i18n("New activity"):model["Name"]
            font.pixelSize: 24
            property string current: model["Current"]
            onCurrentChanged: {
                if (current == "true") {
                    highlightTimer.pendingIndex = index
                    highlightTimer.running = true
                }
            }

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

        highlight: PlasmaCore.FrameSvgItem {
                imagePath: "widgets/viewitem"
                prefix: "normal"
                width: activityList.width
                height: activityList.currentItem.height
                y: activityList.currentItem.y
                Behavior on y {
                    SmoothedAnimation { velocity: 250 }
                }
        }
        
    }
}

