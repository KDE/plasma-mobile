/***************************************************************************
 *   Copyright 2010 Lim Yuen Hoe <yuenhoe@hotmail.com>                     *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/

import Qt 4.7
import org.kde.plasma.core 0.1 as PlasmaCore

Item {
    id: systrayPanel;
    state: "passive";

    PlasmaCore.FrameSvgItem {
        id: hideButtonBackground
        anchors.top: systrayBackground.bottom
        anchors.topMargin: -10
        anchors.horizontalCenter: systrayBackground.horizontalCenter
        width: 128
        height: 58
        imagePath: "widgets/background"
        enabledBorders: "LeftBorder|RightBorder|BottomBorder"
        opacity: systrayPanel.state == "active"?1:0

        Behavior on opacity {
            NumberAnimation { duration: 500 }
        }

        PlasmaCore.SvgItem {
            anchors.centerIn: parent
            /*anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.bottom*/
            width: 48
            height: 48

            svg: PlasmaCore.Svg {
                imagePath: "widgets/arrows"
            }
            elementId: "up-arrow"
            MouseArea {
                anchors.fill: parent
                anchors.bottomMargin: -16
                anchors.leftMargin: -16
                anchors.rightMargin: -16
                onClicked: {
                    systrayPanel.state = "passive"
                }
            }
        }
    }
    PlasmaCore.FrameSvgItem {
        id: systrayBackground
        anchors.fill: systrayPanel
        imagePath: "widgets/background"
        enabledBorders: width < systrayPanel.parent.width?"LeftBorder|RightBorder|BottomBorder":"BottomBorder"
        Item {
            id: containmentParent
            anchors.fill: parent
            anchors.topMargin: systrayBackground.margins.top
            anchors.bottomMargin: systrayBackground.margins.bottom
            anchors.leftMargin: systrayBackground.margins.left
            anchors.rightMargin: systrayBackground.margins.right

            Behavior on opacity {
                NumberAnimation { duration: 200 }
            }
        }
        z: 10
    }

    property QGraphicsWidget containment

    onContainmentChanged: {
        containment.parent = containmentParent
        timer.running = true
    }
    onHeightChanged: resizeTimer.running = true
    onWidthChanged: resizeTimer.running = true

    function updateState()
    {
        state = containment.state
    }

    Timer {
        id: resizeTimer
        interval: 500
        running: false
        repeat: false
        onTriggered: resizeContainment()
        onRunningChanged: {
            if (running) {
                containmentParent.opacity = 0
            } else {
                containmentParent.opacity = 1
            }
        }
     }

    function resizeContainment()
    {
        containment.x = 0
        containment.y = 0
        containment.height = containmentParent.height
        containment.width = containmentParent.width
    }

    states: [
        State {
            name: "active";
            PropertyChanges {
                target: systrayPanel;
                height: 100;
                width: parent.width;
            }
            PropertyChanges {
                target: systrayPanelArea;
                z : 0;
            }
        },
        State {
            name: "passive";
            PropertyChanges {
                target: systrayPanel;
                height: 40;
                width: 400;
            }
            PropertyChanges {
                target: systrayPanelArea;
                z : 500;
            }
        }
    ]


    transitions: [
        Transition {
            from: "passive"
            to: "active"
            reversible: true
            SequentialAnimation {
                NumberAnimation {
                    properties: "x, width, height"
                    duration: 500
                    easing.type: Easing.InOutQuad
                }
            }
        }
    ]
    MouseArea {
        id: systrayPanelArea;
        anchors.fill: parent;
        onClicked: {
            systrayPanel.state = (systrayPanel.state == "active") ? "passive" : "active";
        }
        z: 500;
    }
}
