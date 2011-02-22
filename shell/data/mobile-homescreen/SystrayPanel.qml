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
        anchors.topMargin: -12
        anchors.horizontalCenter: systrayBackground.horizontalCenter
        width: 128
        height: 58
        imagePath: "widgets/background"
        enabledBorders: "LeftBorder|RightBorder|BottomBorder"
        visible: systrayPanel.state == "active"

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
        enabledBorders: "LeftBorder|RightBorder|BottomBorder"
    }

    property QGraphicsWidget containment

    onContainmentChanged: {
        timer.running = true
        containment.stateChanged.connect(updateState)
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
     }

    function resizeContainment()
    {
        containment.x = systrayBackground.margins.left
        containment.y = systrayBackground.margins.top
        containment.height = height - systrayBackground.margins.bottom
        containment.width = width - systrayBackground.margins.left - systrayBackground.margins.right
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
                target: systrayPanelarea;
                z : 0;
            }
        },
        State {
            name: "passive";
            PropertyChanges {
                target: systrayPanel;
                height: 40;
                width: 300;
            }
            PropertyChanges {
                target: systrayPanelarea;
                z : 500;
            }
        }
    ]


    transitions: [
        Transition {
            from: "passive"; to: "active"; reversible: true;
            SequentialAnimation {
                NumberAnimation {
                    properties: "x, width, height";
                    duration: 500;
                    easing.type: Easing.InOutQuad;
                }
            }
        }
    ]
    MouseArea {
        id: systrayPanelarea;
        anchors.fill: parent;
        onClicked: {
            systrayPanel.state = (systrayPanel.state == "active") ? "passive" : "active";
            containment.state = systrayPanel.state
        }
        z: 500;
    }
}
