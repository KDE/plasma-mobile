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

import QtQuick 1.0
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.components 0.1 as PlasmaComponents
//import org.kde.plasma.mobilecomponents 0.1 as MobileComponents
import org.kde.active.settings 0.1


PlasmaCore.FrameSvgItem {
    id: root

    Connections {
        target: timeSettings
        onCurrentTimeChanged: {
            var date = new Date("January 1, 1971 "+timeSettings.currentTime)
            root.hours = date.getHours()
            root.minutes = date.getMinutes()
            root.seconds = date.getSeconds()
        }
    }

    property int hours
    property int minutes
    property int seconds


    imagePath: timePackage.filePath("images", "throbber.svgz")
    anchors {
        horizontalCenter: parent.horizontalCenter
    }
    width: clockRow.width + margins.left + margins.right
    height: clockRow.height + margins.top + margins.bottom

    Row {
        id: clockRow
        spacing: 3
        x: parent.margins.left
        y: parent.margins.top

        Digit {
            model: timeSettings.twentyFour ? 24 : 12
            currentIndex: timeSettings.twentyFour || hours < 12 ? hours : hours - 12
        }
        PlasmaCore.SvgItem {
            svg: PlasmaCore.Svg {imagePath: "widgets/line"}
            elementId: "vertical-line"
            width: naturalSize.width
            anchors {
                top: parent.top
                bottom:parent.bottom
            }
        }
        Digit {
            model: 60
            currentIndex: minutes
        }
        PlasmaCore.SvgItem {
            svg: PlasmaCore.Svg {imagePath: "widgets/line"}
            elementId: "vertical-line"
            width: naturalSize.width
            anchors {
                top: parent.top
                bottom:parent.bottom
            }
        }
        Digit {
            model: 60
            currentIndex: seconds
        }
        PlasmaCore.SvgItem {
            visible: !timeSettings.twentyFour
            svg: PlasmaCore.Svg {imagePath: "widgets/line"}
            elementId: "vertical-line"
            width: naturalSize.width
            anchors {
                top: parent.top
                bottom:parent.bottom
            }
        }
        Digit {
            visible: !timeSettings.twentyFour
            model: ListModel {
                ListElement {
                    meridiae: "AM"
                }
                ListElement {
                    meridiae: "PM"
                }
            }
            delegate: Text {
                text: meridiae
                font.pointSize: 25
            }
            currentIndex: hours > 12 ? 1 : 0
        }
    }
}
