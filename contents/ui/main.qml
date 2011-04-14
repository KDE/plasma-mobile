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
         model: PlasmaCore.DataModel{
                    dataSource: activitySource
                }
         pathItemCount: 7
         property int delegateWidth: 400
         property int delegateHeight: delegateWidth/1.6

         preferredHighlightBegin: 0.5
         preferredHighlightEnd: 0.5


         delegate: ActivityDelegate{}

         path: Path {
             startX: mainView.width
             startY: 0
             PathAttribute { name: "itemScale"; value: 0.1 }
             PathAttribute { name: "itemOpacity"; value: 0 }
             PathAttribute { name: "translate"; value: 0 }
             PathAttribute { name: "z"; value: 0 }
             
             
             PathLine {
                 x: mainView.width-100
                 y: mainView.height/4
             }
             PathAttribute { name: "itemScale"; value: 0.2 }
             PathAttribute { name: "itemOpacity"; value: 1 }
             PathAttribute { name: "translate"; value: -100 }
             PathAttribute { name: "z"; value: 0 }
             
             PathQuad {
                 x: mainView.width-mainView.delegateWidth/2
                 y: mainView.height/2
                 controlX: mainView.width-mainView.delegateWidth/1.8
                 controlY: mainView.height/3
             }

             PathAttribute { name: "itemScale"; value: 1 }
             PathAttribute { name: "itemOpacity"; value: 1 }
             PathAttribute { name: "translate"; value: 0 }
             PathAttribute { name: "z"; value: 100 }



             PathLine {
                 x: mainView.width-100
                 y: 3*(mainView.height/4)
             }
             PathAttribute { name: "itemScale"; value: 0.2 }
             PathAttribute { name: "itemOpacity"; value: 1 }
             PathAttribute { name: "translate"; value: 100 }
             PathAttribute { name: "z"; value: 0 }


             PathLine {
                 x: mainView.width
                 y: mainView.height
             }
             PathAttribute { name: "itemScale"; value: 0.1 }
             PathAttribute { name: "itemOpacity"; value: 0 }
             PathAttribute { name: "translate"; value: 0 }
             PathAttribute { name: "z"; value: 0 }
         }
     }
 }
