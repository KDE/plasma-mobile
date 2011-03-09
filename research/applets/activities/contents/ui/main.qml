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

Rectangle {
    width: 240; height: 500
    color: "black"

    ActivitiesModel {
        id: activitiesModel
    }

     PathView {
         id: mainView
         anchors.fill: parent
         model: activitiesModel
         pathItemCount: 6
         property int delegateWidth: 200
         property int delegateHeight: 120
         
         preferredHighlightBegin: 0.25
         preferredHighlightEnd: 0.25


         delegate: Rectangle {
             id: delegate
             scale: PathView.itemScale
             opacity: PathView.itemOpacity
             z: PathView.z

             transform: Rotation {
                 origin.x: 0
                 origin.y: delegate.height
                 angle: -PathView.itemRotation
             }

             width: mainView.delegateWidth
             height: mainView.delegateHeight
             
             Text{
                 text: "opacity"+parent.opacity
            }
         }
         clip:true
         //offset: 2

         path: Path {
             startX: mainView.width/4+16
             startY: mainView.height-mainView.delegateHeight+16
             PathAttribute { name: "itemScale"; value: 1.0 }
             PathAttribute { name: "itemOpacity"; value: 0 }
             PathAttribute { name: "itemRotation"; value: 0 }
             PathAttribute { name: "z"; value: 0 }
             PathLine {
                 x: mainView.width/4
                 y: mainView.height-mainView.delegateHeight
            }
            PathAttribute { name: "itemScale"; value: 1 }
            PathAttribute { name: "itemOpacity"; value: 1 }
            PathAttribute { name: "itemRotation"; value: 0 }
            PathAttribute { name: "z"; value: 100 }

            PathLine {
                 x: mainView.width/4-48
                 y: mainView.height-mainView.delegateHeight-48
            }
            PathAttribute { name: "itemScale"; value: 0.5 }
            PathAttribute { name: "itemOpacity"; value: 0 }
            PathAttribute { name: "itemRotation"; value: 45 }
            PathAttribute { name: "z"; value: 0 }

         }
     }
 }
