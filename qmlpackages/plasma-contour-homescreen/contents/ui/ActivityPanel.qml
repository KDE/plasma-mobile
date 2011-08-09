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
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents

Item {
    id: activityPanel;
    anchors {
        top: parent.top
        bottom: parent.bottom
        topMargin: 50
    }
    width: 400
    state: "show"
    property Item switcher
    onStateChanged: {
        if (state == "hidden") {
            switcher.state = "Passive"
        } else if (switcher.state == "Passive") {
            switcher.state = "Normal"
        }
    }

    Connections {
        target: switcher
        onNewActivityRequested: homeScreen.newActivityRequested()
    }

    //Uses a MouseEventListener instead of a MouseArea to not block any mouse event
    MobileComponents.MouseEventListener {
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
                    if (activityPanel.switcher.state != "AcceptingInput") {
                        hideTimer.restart()
                    }
                } else {
                    activityPanel.state = "hidden"
                }
        }

        PlasmaCore.FrameSvgItem {
            id: hint
            x: 20
            width: 40
            height: 80
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: -50
            imagePath: "widgets/background"
            enabledBorders: "LeftBorder|TopBorder|BottomBorder"
            PlasmaCore.SvgItem {
                width:22
                height:22
                svg: PlasmaCore.Svg {
                    imagePath: homeScreenPackage.filePath("images", "panel-icons.svgz")
                }
                elementId: "activities"
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                    leftMargin: hint.margins.left
                }
            }
            MouseArea {
                anchors.fill: parent
                onClicked: activityPanel.state = "show"
            }
        }
    }

    Timer {
        id: hideTimer
        interval: 4000;
        running: false;
        onTriggered:  {
            if (activityPanel.switcher.state != "AcceptingInput") {
                activityPanel.state = "hidden"
            }
        }
    }

    MobileComponents.Package {
        id: switcherPackage
        name: "org.kde.activityswitcher"
        Component.onCompleted: {
            var component = Qt.createComponent(switcherPackage.filePath("mainscript"));
            activityPanel.switcher = component.createObject(hintregion);
        }
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
