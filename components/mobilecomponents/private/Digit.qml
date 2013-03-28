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


Item {
    id: root

    property alias model: spinnerView.model
    property alias currentIndex: spinnerView.currentIndex
    property alias delegate: spinnerView.delegate
    property alias moving: spinnerView.moving
    property int selectedIndex: -1

    width: placeHolder.width*1.7
    height: placeHolder.height*9

    Text {
        id: placeHolder
        visible: false
        font.pointSize: 12
        font.weight: Font.DemiBold
        text: "0000"
    }

    PathView {
        id: spinnerView
        anchors.centerIn: parent
        height:placeHolder.height * 7
        width: placeHolder.width

        model: 60
        clip: true
        pathItemCount: 5
        dragMargin: 800
        preferredHighlightBegin: 0.5
        preferredHighlightEnd: 0.5
        delegate: Text {
            horizontalAlignment: Text.AlignHCenter
            width: spinnerView.width
            property int ownIndex: index
            text: index < 10 ? "0"+index : index
            font.pointSize: 12
            font.weight: Font.DemiBold
            opacity: PathView.itemOpacity
        }

        onMovingChanged: {
            userConfiguring = true
            if (!moving) {
                userConfiguringTimer.restart()
                selectedIndex = childAt(width/2, height/2).ownIndex
            }
        }

        path: Path {
            startX: spinnerView.width/2
            startY: spinnerView.height + 1.5*placeHolder.height
            PathAttribute { name: "itemOpacity"; value: -0.8 }
            PathLine {
                x: spinnerView.width/2
                y: spinnerView.height/2
            }
            PathAttribute { name: "itemOpacity"; value: 1 }
            PathLine {
                x: spinnerView.width/2
                y: -1.5*placeHolder.height
            }
            PathAttribute { name: "itemOpacity"; value: -0.8 }
        }
    }

    PlasmaCore.SvgItem {
        svg: PlasmaCore.Svg {imagePath: "widgets/line"}
        elementId: "horizontal-line"
        height: naturalSize.heigth
        anchors {
            left: parent.left
            right:parent.right
            top: parent.top
            topMargin: parent.height * 0.36
        }
    }
    PlasmaCore.SvgItem {
        svg: PlasmaCore.Svg {imagePath: "widgets/line"}
        elementId: "horizontal-line"
        height: naturalSize.heigth
        anchors {
            left: parent.left
            right:parent.right
            bottom: parent.bottom
            bottomMargin: parent.height * 0.36
        }
    }

    //FIXME  propper functionality, larger hit area... custom button?
    PlasmaComponents.ToolButton {
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.top
        }

        iconSource: "go-up"

        opacity: 0.8

        onClicked: spinnerView.incrementCurrentIndex()
    }
    PlasmaComponents.ToolButton {
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
        }

        iconSource: "go-down"

        opacity: 0.8

        onClicked: spinnerView.decrementCurrentIndex()
    }

}

