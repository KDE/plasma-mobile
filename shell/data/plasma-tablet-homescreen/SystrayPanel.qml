/***************************************************************************
 *   Copyright 2010 Lim Yuen Hoe <yuenhoe@hotmail.com>                     *
 *   Copyright 2011 Davide Bettio <bettio@kde.org>                         *
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
    state: "passive"
    height: handle.height + handle.y;
    width:  parent.width;

    Rectangle {
        id: handle
        anchors.right: parent.right
        width: 20
        height: 40
        z: systrayBackground.z + 1
        MouseArea {
            id: handleArea;
            anchors.fill: parent;
            onReleased: {
                if ((systrayPanel.state == "passive") && ((handle.y > 200) || (handle.y == 0))){
                    systrayPanel.state = "active";
                }else{
                    //horrible hack to force a change of state when we change from passive to passive
                    systrayPanel.state = "tmp-passive";
                    systrayPanel.state = "passive";
                }
            }
            drag.target: parent
            drag.axis: Drag.YAxis
            drag.minimumY: 0
            drag.maximumY: systrayPanel.parent.height - parent.height
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
        containment.y =  containmentParent.height - 35
        containment.height = 35
        containment.width = containmentParent.width
    }

    states: [
        State {
            name: "active";
            PropertyChanges {
                target: handle
                y: systrayPanel.parent.height - handle.height;
            }
        },
        State {
            name: "passive";
            PropertyChanges {
                target: handle
                y: 0
            }
        }
    ]


    transitions: [
        Transition {
            reversible: true
            SequentialAnimation {
                NumberAnimation {
                    properties: "y, height"
                    duration: 500
                    easing.type: Easing.InOutQuad
                }
            }
        }
    ]
}
