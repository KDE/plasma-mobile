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
        onWidthChanged: {
            clockSvg.size = face.width+"x"+face.height
        }
        onHeightChanged: {
            clockSvg.size = face.width+"x"+face.height
        }
    }

    Hand {
        anchors.topMargin: 3
        elementId: "HourHandShdow"
        rotation: 180 + hours * 30 + (minutes/2)
    }
    Hand {
        elementId: "HourHand"
        rotation: 180 + hours * 30 + (minutes/2)
    }


    Hand {
        anchors.topMargin: 3
        elementId: "MinuteHandShadow"
        rotation: 180 + minutes * 6
    }
    Hand {
        elementId: "MinuteHand"
        rotation: 180 + minutes * 6
    }
/*
    Hand {
        anchors.topMargin: 3
        elementId: "SecondHandShadow"
        rotation: 180 + seconds * 6
    }
    Hand {
        elementId: "SecondHand"
        rotation: 180 + seconds * 6
    }
*/

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
