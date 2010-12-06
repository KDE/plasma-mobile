/*
 *   Author: Marco Martin <mart@kde.org>
 *   Date: Mon Dec 6 2010, 19:01:32
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
import org.kde.plasma.graphicswidgets 0.1 as PlasmaWidgets
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.graphicslayouts 4.7 as GraphicsLayouts

Item {
    id: main
    width: 200
    height: 200

    property int hours
    property int minutes
    property int seconds

    Component.onCompleted: {
        plasmoid.backgroundHints = "NoBackground"
        plasmoid.addEventListener("dataUpdated", dataUpdated)
        dataEngine("time").connectSource("Local", main, 30*500)
    }
    
    function dataUpdated(source, data)
    {
        var date = new Date("January 1, 1971 "+data.Time);
        hours = date.getHours()
        minutes = date.getMinutes()
        seconds = date.getSeconds()
    }

    onWidthChanged: {
        clockSvg.size = face.width+"x"+face.height
    }
    onHeightChanged: {
        clockSvg.size = face.width+"x"+face.height
    }

    PlasmaCore.Svg {
        id: clockSvg
        imagePath: "widgets/clock"
    }
    PlasmaCore.SvgItem {
        id:face
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        width: Math.min(parent.width, parent.height)
        height: Math.min(parent.width, parent.height)
        svg: clockSvg
        elementId: "ClockFace"
    }

    PlasmaCore.SvgItem {
        id: hourHand
        width: naturalSize.width
        height: naturalSize.height
        anchors.top: center.verticalCenter
        anchors.horizontalCenter: center.horizontalCenter
        svg: clockSvg
        elementId: "HourHand"
        smooth: true
        transform: Rotation {
            id: hourRotation
            angle: 180 + hours * 6
            origin.x: hourHand.naturalSize.width/2; origin.y: 0;
            Behavior on angle {
                SpringAnimation { spring: 2; damping: 0.2; modulus: 360 }
            }
        }
    }

    PlasmaCore.SvgItem {
        id: minuteHand
        width: naturalSize.width
        height: naturalSize.height
        anchors.top: center.verticalCenter
        anchors.horizontalCenter: center.horizontalCenter
        svg: clockSvg
        elementId: "MinuteHand"
        smooth: true
        transform: Rotation {
            id: minuteRotation
            angle: 180 + minutes * 6
            origin.x: minuteHand.naturalSize.width/2; origin.y: 0;
            Behavior on angle {
                SpringAnimation { spring: 2; damping: 0.2; modulus: 360 }
            }
        }
    }
   /* 
    PlasmaCore.SvgItem {
        id: secondHand
        width: naturalSize.width
        height: naturalSize.height
        anchors.top: center.verticalCenter
        anchors.horizontalCenter: center.horizontalCenter
        svg: clockSvg
        elementId: "SecondHand"
        smooth: true
        transform: Rotation {
            id: secondRotation
            angle: 180 + seconds * 6
            origin.x: secondHand.naturalSize.width/2; origin.y: 0;
            Behavior on angle {
                SpringAnimation { spring: 2; damping: 0.2; modulus: 360 }
            }
        }
    }*/

    PlasmaCore.SvgItem {
        id: center
        width: naturalSize.width
        height: naturalSize.height
        anchors.horizontalCenter: face.horizontalCenter
        anchors.verticalCenter: face.verticalCenter
        svg: clockSvg
        elementId: "HandCenterScrew"
    }
    PlasmaCore.SvgItem {
        anchors.fill: face
        svg: clockSvg
        elementId: "Glass"
    }

}
