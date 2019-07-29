/*
 *  Copyright 2019 Marco Martin <mart@kde.org>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  2.010-1301, USA.
 */

import QtQuick 2.4
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.3 as Controls

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kquickcontrolsaddons 2.0


MouseArea {
    id: root

    property alias availableCellHeight: launcherGrid.availableCellHeight
    property alias contentY: mainFlickable.contentY
    property alias contentHeight: mainFlickable.contentHeight
    property alias topMargin: mainFlickable.topMargin
    property int leftPadding
    property int rightPadding
    signal movementEnded
    signal externalDragStarted

    drag.filterChildren: true

    onClicked: closeAnim.restart()

//BEGIN functions
    //Autoscroll related functions
    function scrollUp() {
        autoScrollTimer.scrollDown = false;
        autoScrollTimer.running = true;
        scrollUpIndicator.opacity = 1;
        scrollDownIndicator.opacity = 0;
    }

    function scrollDown() {
        autoScrollTimer.scrollDown = true;
        autoScrollTimer.running = true;
        scrollUpIndicator.opacity = 0;
        scrollDownIndicator.opacity = 1;
    }

    function stopScroll() {
        autoScrollTimer.running = false;
        scrollUpIndicator.opacity = 0;
        scrollDownIndicator.opacity = 0;
    }
//END functions

    Timer {
        id: autoScrollTimer
        property bool scrollDown: true
        repeat: true
        interval: 1500
        onTriggered: {
            //reordering launcher icons
            if (launcherGrid.reorderingApps) {
                scrollAnim.to = scrollDown ?
                //Scroll down
                    Math.min(mainFlickable.contentItem.height -  root.height, mainFlickable.contentY + root.height/2) :
                //Scroll up
                    Math.max(0, mainFlickable.contentY - root.height/2);

            } else {
                stopScroll();
            }
            scrollAnim.running = true;
        }
    }

    NumberAnimation {
        id: scrollAnim
        target: mainFlickable
        property: "contentY"
        duration: units.longDuration
        easing.type: Easing.InOutQuad
    }

    PlasmaCore.Svg {
        id: arrowsSvg
        imagePath: "widgets/arrows"
    }
    PlasmaCore.SvgItem {
        id: scrollUpIndicator
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.top
            topMargin: 300
        }
        z: 2
        opacity: 0
        svg: arrowsSvg
        elementId: "up-arrow"
        width: units.iconSizes.large
        height: width
        Behavior on opacity {
            OpacityAnimator {
                duration: 1000
                easing.type: Easing.InOutQuad
            }
        }
    }
    PlasmaCore.SvgItem {
        id: scrollDownIndicator
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            bottomMargin: units.gridUnit * 2
        }
        z: 2
        opacity: 0
        svg: arrowsSvg
        elementId: "down-arrow"
        width: units.iconSizes.large
        height: width
        Behavior on opacity {
            OpacityAnimator {
                duration: 1000
                easing.type: Easing.InOutQuad
            }
        }
    }

    Flickable {
        id: mainFlickable
        anchors{
            fill: parent
            leftMargin: root.leftPadding
            rightMargin: root.rightPadding
        }
        contentWidth: width
        contentHeight: launcherGrid.height
        onMovementEnded: root.movementEnded();
        onFlickEnded: root.movementEnded();
        LauncherGrid {
            id: launcherGrid
            width: parent.width
            onExternalDragStarted: root.externalDragStarted()
            onDragPositionChanged: {
                pos = mapToItem(root, pos.x, pos.y);

                if (pos.y < root.height /3) {
                    scrollUp();
                } else if (pos.y > root.height / 3 * 2) {
                    scrollDown();
                } else {
                    stopScroll();
                }
            }
        }
    }

    PlasmaComponents.ScrollBar {
        anchors {
            top: parent.top
            right: parent.right
            bottom: parent.bottom
            topMargin: Math.max(0, -mainFlickable.contentY) + units.smallSpacing*2
            rightMargin: root.rightPadding + units.smallSpacing * 2
        }
        interactive: false
        flickableItem: mainFlickable
    }
}
