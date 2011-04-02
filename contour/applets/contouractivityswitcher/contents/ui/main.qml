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
import org.kde.plasma.core 0.1 as PlasmaCore

Item {
    width: 240; height: 500

    Component.onCompleted: {
        plasmoid.containmentType = "CustomContainment"
        plasmoid.movableApplets = false
    }

    PlasmaCore.DataSource {
        id: activityThumbnailsSource
        engine: "org.kde.mobileactivitythumbnails"
        connectedSources: activitySource.sources
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

    //FIXME: why a timer is needed?
    Timer {
        id: highlightTimer
        interval: 250;
        running: false;
        property int pendingIndex: -1
        onTriggered:  {
            mainView.currentIndex = pendingIndex
        }
    }

     PathView {
         id: mainView
         anchors.fill: parent
         anchors.bottomMargin: 32
         anchors.leftMargin: 64
         interactive: false
         model: PlasmaCore.DataModel{
                    dataSource: activitySource
                }
         pathItemCount: 6
         property int delegateWidth: mainView.width/1.5
         property int delegateHeight: mainView.height/1.5

         preferredHighlightBegin: 0.5
         preferredHighlightEnd: 0.5


         delegate: ActivityDelegate{}
         clip:true

         MouseArea {
             anchors.fill: parent
             property int downX
             property int downY

             onPressed: {
                 downX = mouse.x
                 downY = mouse.y
             }

             onReleased: {
                 if (mouse.x < downX && mouse.y > downY) {
                     if (mainView.currentIndex < mainView.count) {
                         ++mainView.currentIndex
                     } else {
                         mainView.currentIndex = 0
                     }
                 } else if (mouse.x > downX && mouse.y < downY) {
                     if (mainView.currentIndex > 0) {
                         --mainView.currentIndex
                     } else {
                         mainView.currentIndex = mainView.count-1
                     }
                 }
            }
         }

         path: Path {
             startX: mainView.width/2.3
             startY: mainView.height-mainView.delegateHeight/1.5+32
             PathAttribute { name: "itemScale"; value: 1.0 }
             PathAttribute { name: "itemOpacity"; value: 0 }
             PathAttribute { name: "itemRotation"; value: 0 }
             PathAttribute { name: "z"; value: 99 }
             PathLine {
                 x: mainView.width/2
                 y: mainView.height-mainView.delegateHeight/1.5-16
            }
            PathAttribute { name: "itemScale"; value: 1 }
            PathAttribute { name: "itemOpacity"; value: 1 }
            PathAttribute { name: "itemRotation"; value: 0 }
            PathAttribute { name: "z"; value: 100 }

            PathLine {
                 x: mainView.width/1.8
                 y: mainView.height-mainView.delegateHeight/1.5
            }
            PathAttribute { name: "itemScale"; value: 0.3 }
            PathAttribute { name: "itemOpacity"; value: 0 }
            PathAttribute { name: "itemRotation"; value: 45 }
            PathAttribute { name: "z"; value: 0 }

         }
     }
 }
