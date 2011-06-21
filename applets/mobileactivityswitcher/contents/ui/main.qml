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
    width: 240
    height: 300
    property int iconSize: 32

    Component.onCompleted: {
        plasmoid.containmentType = "CustomContainment"
        plasmoid.drawWallpaper = false
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
        interval: 250
        running: false
        repeat: false
        property int pendingIndex: -1
        onTriggered:  {
            mainView.currentIndex = pendingIndex
        }
    }

    PlasmaCore.Svg {
        id: iconsSvg
        imagePath: "widgets/configuration-icons"
    }

     PathView {
         id: mainView
         anchors.fill: parent
         anchors.bottomMargin: 32
         anchors.leftMargin: 64
         model: PlasmaCore.SortFilterModel {
            sourceModel: PlasmaCore.DataModel {
                dataSource: activitySource
            }
            filterRole: "Name"
            filterRegExp: ".*"+actionsToolBar.query+".*"
         }
         pathItemCount: 5
         property int delegateWidth: 400
         //FIXME: the 100 is the handle width
         property int delegateHeight: (delegateWidth-100)/1.6

         preferredHighlightBegin: 0.5
         preferredHighlightEnd: 0.5


         delegate: ActivityDelegate{}

         path: Path {
             startX: mainView.width
             startY: 0
             PathAttribute { name: "itemScale"; value: 0.1 }
             PathAttribute { name: "itemOpacity"; value: 0 }
             PathAttribute { name: "z"; value: 0 }

             PathLine {
                 x: mainView.width-150
                 y: -35
             }
             PathAttribute { name: "itemScale"; value: 0.2 }
             PathAttribute { name: "itemOpacity"; value: 0.3 }
             PathAttribute { name: "z"; value: 0 }

             PathLine {
                 x: mainView.width-mainView.delegateWidth/2
                 y: mainView.height/2
             }

             PathAttribute { name: "itemScale"; value: 1 }
             PathAttribute { name: "itemOpacity"; value: 1 }
             PathAttribute { name: "z"; value: 100 }



             PathLine {
                 x: mainView.width-150
                 y: mainView.height+35
             }
             PathAttribute { name: "itemScale"; value: 0.2 }
             PathAttribute { name: "itemOpacity"; value: 0.3 }
             PathAttribute { name: "z"; value: 0 }


             PathLine {
                 x: mainView.width
                 y: mainView.height
             }
             PathAttribute { name: "itemScale"; value: 0.1 }
             PathAttribute { name: "itemOpacity"; value: 0 }
             PathAttribute { name: "z"; value: 0 }
         }
     }

     ToolBar {
        id: actionsToolBar
     }
 }
