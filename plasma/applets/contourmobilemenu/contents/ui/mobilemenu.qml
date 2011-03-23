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
import org.kde.qtextracomponents 4.7

Item {
    width: 240; height: 500

    SuggestionModel {
        id: suggestionModel
    }

    PlasmaCore.Svg{
        id: iconsSvg
        imagePath: plasmoid.file("images", "icons.svgz")
    }


     PathView {
         id: mainView
         anchors.fill: parent
         model: suggestionModel

         property int activityRootX: 64
         property int activityRootY: 64

         delegate: SuggestionDelegate {}
         clip:true
         offset: 2
         path: Path {
             startX: mainView.width/2; startY: -100
             /*PathAttribute { name: "delegateScale"; value: 1.0 }
             PathAttribute { name: "delegateOpacity"; value: 1.0 }*/
             PathQuad {
                 x: 0
                 y: mainView.height+100
                 controlX: mainView.width
                 controlY: mainView.height/2
            }

         }
     }
     PlasmaCore.SvgItem {
        id: activityRootSvg
        //anchors.verticalCenter: parent.verticalCenter
        width: 128
        height: 128
        svg: iconsSvg
        elementId: "activity-root"
    }
 }
