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
 *   GNU Library General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 2.2
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.mobilecomponents 0.2 as MobileComponents
import org.kde.activities 0.1 as Activities

Item {
    id: activitySwitcher
    anchors.fill: parent
    property int iconSize: 32
    signal newActivityRequested
    state: "Passive"
    property real maxScore: 0

    onStateChanged: {
        if (state == "Passive") {
            highlightTimer.restart()
        }
    }

    Activities.ActivityModel {
        id: activitiesSource

        shownStates: "Running,Stopping"
    }

    //FIXME: delete after stoppping: otherwise another empty activity will be created
    Timer {
        id: deleteTimer
        interval: 200
        repeat: false
        running: false
        property string activityId
        onTriggered: {
            activitiesSource.removeActivity(activityId, function() {})
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
            if (activitySwitcher.state == "Passive") {
                mainView.currentIndex = pendingIndex

                // close all opened deleteDialogs since ActivitySwitcher panel is now hidden.
                mainView.deleteDialogOpenedAtIndex = -1
            }
        }
    }

    PlasmaCore.Svg {
        id: iconsSvg
        imagePath: "widgets/configuration-icons"
    }

     PathView {
         id: mainView
         anchors {
             left: parent.left
             right: parent.right
             verticalCenter: parent.verticalCenter
             leftMargin: 64
         }
         //limit the height if only few items are shown
         height: (delegateHeight * Math.min(count, pathItemCount)) / 1.5

         model: PlasmaCore.SortFilterModel {
            sourceModel: activitiesSource
            filterRole: "Name"
            filterRegExp: ".*"+actionsToolBar.query+".*"
         }
         pathItemCount: 5
         property int delegateWidth: 400
         //FIXME: the 100 is the handle width
         property int delegateHeight: (delegateWidth-100)/1.6

         preferredHighlightBegin: 0.5
         preferredHighlightEnd: 0.5

         flickDeceleration: 600

         property int deleteDialogOpenedAtIndex: -1
         delegate: ActivityDelegate{}

         path: Path {
             startX: mainView.width-mainView.delegateWidth/2
             startY: 0
             PathAttribute { name: "itemXTranslate"; value: mainView.delegateWidth/3 }
             PathAttribute { name: "itemYTranslate"; value: 20 }
             PathAttribute { name: "itemScale"; value: 0.3 }
             PathAttribute { name: "itemOpacity"; value: 0 }
             PathAttribute { name: "z"; value: 0 }


             PathLine {
                 x: mainView.width-mainView.delegateWidth/2
                 y: mainView.height/4
             }

             PathAttribute { name: "itemXTranslate"; value: mainView.delegateWidth/4 }
             PathAttribute { name: "itemYTranslate"; value: -50 }
             PathAttribute { name: "itemScale"; value: 0.5 }
             PathAttribute { name: "itemOpacity"; value: 1 }
             PathAttribute { name: "z"; value: 0 }


             PathLine {
                 x: mainView.width-mainView.delegateWidth/2
                 y: mainView.height/2
             }

             PathAttribute { name: "itemXTranslate"; value: 0 }
             PathAttribute { name: "itemYTranslate"; value: 0 }
             PathAttribute { name: "itemScale"; value: 1 }
             PathAttribute { name: "z"; value: 0 }


             PathLine {
                 x: mainView.width-mainView.delegateWidth/2
                 y: mainView.height/4*3
             }

             PathAttribute { name: "itemXTranslate"; value: mainView.delegateWidth/4 }
             PathAttribute { name: "itemYTranslate"; value: 50 }
             PathAttribute { name: "itemScale"; value: 0.5 }
             PathAttribute { name: "itemOpacity"; value: 1 }
             PathAttribute { name: "z"; value: 0 }


             PathLine {
                 x: mainView.width-mainView.delegateWidth/2
                 y: mainView.height
             }

             PathAttribute { name: "itemXTranslate"; value: mainView.delegateWidth/3 }
             PathAttribute { name: "itemScale"; value: 0.3 }
             PathAttribute { name: "itemOpacity"; value: 0 }
             PathAttribute { name: "z"; value: 0 }
         }
     }

     ToolBar {
        id: actionsToolBar
     }
 }
