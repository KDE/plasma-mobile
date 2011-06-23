/***************************************************************************
 *   Copyright 2010 Alexis Menard <menard@kde.org>                         *
 *   Copyright 2010 Artur Duque de Souza <asouza@kde.org>                  *
 *   Copyright 2010 Marco Martin <mart@kde.org>                            *
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
import org.kde.plasma.mobilecomponents 0.1

Item {
    id: activityPanel;
    height: parent.height/1.5
    width: 400
    state: "show"

    function addContainment(cont)
    {
        containment = cont
    }

    AppletStatusWatcher {
        id: appletStatusWatcher
        onStatusChanged: {
            if (status == AppletStatusWatcher.AcceptingInputStatus) {
                hideTimer.running = false
            } else {
                hideTimer.restart()
            }
        }
    }

    //Uses a MouseEventListener instead of a MouseArea to not block any mouse event
    MouseEventListener {
        id: hintregion;

        anchors.fill: parent
        anchors.leftMargin: -60

        property int startX
        property int startMouseX
        onPressed: {
            startMouseX = mouse.screenX
            startX = activityPanel.x
            hideTimer.running = false
            activityPanel.state = "dragging"
        }

        onPositionChanged: {
            activityPanel.x = Math.max(startX + (mouse.screenX - startMouseX),
                                    activityPanel.parent.width - activityPanel.width)
            hideTimer.running = false
        }

        onReleased: {
            if (activityPanel.x < activityPanel.parent.width - activityPanel.width/2) {
                    activityPanel.state = "show"
                    if (appletStatusWatcher.status != AppletStatusWatcher.AcceptingInputStatus) {
                        hideTimer.restart()
                    }
                } else {
                    activityPanel.state = "hidden"
                }
        }

        Item {
            id: containmentItem
            x: 60
            width: parent.width
            height: parent.height
        }

        PlasmaCore.FrameSvgItem {
            id: hint
            x: 20
            width: 40
            height: 80
            anchors.verticalCenter: parent.verticalCenter
            imagePath: "widgets/background"
            enabledBorders: "LeftBorder|TopBorder|BottomBorder"
            PlasmaCore.SvgItem {
                width:32
                height:32
                svg: PlasmaCore.Svg {
                    imagePath: "widgets/arrows"
                }
                elementId: "left-arrow"
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
            }
            MouseArea {
                anchors.fill: parent
                onClicked: activityPanel.state = "show"
            }
        }
    }

    Timer {
        id : hideTimer
        interval: 4000;
        running: false;
        onTriggered:  {
            if (appletStatusWatcher.status != AppletStatusWatcher.AcceptingInputStatus) {
                activityPanel.state = "hidden"
            }
        }
    }

    property QGraphicsWidget containment
    onContainmentChanged: {
        containment.parent = containmentItem
        containment.x = 0
        containment.y = 0
        containment.width = activityPanel.width
        containment.height = activityPanel.height
        appletStatusWatcher.plasmoid = containment
    }

    states: [
        State {
            name: "show";
            PropertyChanges {
                target: activityPanel;
                x: parent.width - width;
            }
            PropertyChanges {
                target: hint;
                opacity: 0;
            }
            PropertyChanges {
                target: hideTimer;
                running: true
            }
        },
        State {
            name: "hidden";
            PropertyChanges {
                target: activityPanel;
                x: parent.width;
            }
            PropertyChanges {
                target: hint;
                opacity: 1;
            }
        },
        State {
            name: "dragging"
            PropertyChanges {
                target: activityPanel;
                x: activityPanel.x;
                y: activityPanel.y;

            }
            PropertyChanges {
                target: hint;
                opacity: 0;
            }
        }
    ]

    transitions: [
        Transition {
            from: "show";
            to: "hidden";
            SequentialAnimation {
                ParallelAnimation {
                    NumberAnimation {
                        targets: activityPanel;
                        properties: "x";
                        duration: 1000;
                        easing.type: "InOutCubic";
                    }
                }
                ParallelAnimation {
                    PropertyAnimation {
                        target: hint;
                        property: "opacity";
                        duration: 600;
                        easing.type: "InCubic";
                    }
                }
            }
        },
        Transition {
            from: "hidden";
            to: "show";
            SequentialAnimation {
                ParallelAnimation {
                    PropertyAnimation {
                        targets: hint;
                        properties: "opacity";
                        duration: 600;
                        easing.type: "OutCubic";
                    }
                }
                ParallelAnimation {
                    NumberAnimation {
                        targets: activityPanel;
                        properties: "x";
                        duration: 800;
                        easing.type: "InOutCubic";
                    }
                }
            }
        },
        Transition {
            from: "dragging";
            to: "*";
            NumberAnimation {
                properties: "x,y";
                easing.type: "OutQuad";
                duration: 400;
            }
        },
        Transition {
            from: "*";
            to: "dragging";
            ParallelAnimation {
                PropertyAnimation {
                    targets: hint;
                    properties: "opacity";
                    duration: 600;
                    easing.type: "OutCubic";
                }
            }
        }
    ]

}
